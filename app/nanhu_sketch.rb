# frozen_string_literal: true
require 'app/nanhu_strokes.rb'
require 'app/nanhu_curves.rb'
require 'app/nanhu_architecture_detail.rb'

# A distance-revealed vector drawing, not a raster sketch effect. All strokes
# live in the original photograph's coordinates and share its camera transform.
module NanhuSketch
  # Discard compiled geometry when this source is hot-reloaded in development.
  @strokes = nil
  @drawing_complete = false

  def self.smooth(value)
    value = [[value, 0.0].max, 1.0].min
    value * value * (3.0 - 2.0 * value)
  end

  def self.ramp(time, start, finish)
    smooth((time - start) / (finish - start))
  end

  def self.crop(time)
    # Freeze registration during drawing and photographic development. Only
    # after the pencil disappears does a very gentle photographic push begin.
    zoom = 1.015 + 0.010 * ramp(time, 18.5, 21.0)
    scale = 720.0 / 968.0 * zoom
    width = 804.0 / scale
    height = 720.0 / scale
    { x: (1920.0 - width) * 0.46, y: (968.0 - height) * 0.52,
      w: width, h: height, scale: scale }
  end

  def self.point(point, crop)
    [(point[0] - crop[:x]) * crop[:scale],
     (968.0 - point[1] - crop[:y]) * crop[:scale]]
  end

  def self.native_lines(a, b, opacity)
    camera = crop(0)
    a = point(a, camera)
    b = point(b, camera)
    [0.0, 0.65].map do |offset|
      { x: a[0] * 2, y: a[1] * 2 + offset,
        x2: b[0] * 2, y2: b[1] * 2 + offset,
        r: 53, g: 65, b: 65, a: opacity.round, primitive_marker: :line }
    end
  end

  def self.compile
    groups = NanhuStrokes::GROUPS.map do |group|
      { start: group[:start], finish: group[:finish], opacity: group[:opacity], paths: group[:paths].map { |p| p.map { |xy| xy.dup } } }
    end
    # Remove former straight waterfront strokes; editable interpolating curves
    # now follow the same photographed shoreline landmarks.
    groups[0][:paths] = groups[0][:paths][4..-1]
    groups.each do |group|
      group[:start] = 0.65 + (group[:start] - 1.6) * 0.40
      group[:finish] = 0.65 + (group[:finish] - 1.6) * 0.40
    end
    groups += NanhuCurves.groups
    groups += NanhuArchitectureDetail.groups
    groups.map do |group|
      lengths = group[:paths].map do |path|
        path.each_cons(2).map { |a, b| Math.sqrt((b[0] - a[0])**2 + (b[1] - a[1])**2) }.inject(0.0, :+)
      end
      total = lengths.inject(0.0, :+)
      cursor = 0.0
      paths = group[:paths].each_with_index.map do |path, i|
        duration = (group[:finish] - group[:start]) * lengths[i] / total
        opacity = group[:opacity] * (0.92 + 0.08 * Math.sin(i * 1.7))
        segments = path.each_cons(2).map do |a, b|
          { a: a, b: b, length: Math.sqrt((b[0] - a[0])**2 + (b[1] - a[1])**2),
            output: [a, b, opacity], native: native_lines(a, b, opacity) }
        end
        record = { points: path, length: lengths[i], start: group[:start] + cursor,
          duration: duration, opacity: opacity, segments: segments,
          native: segments.map { |segment| segment[:native] }.flatten }
        cursor += duration
        record
      end
      { opacity: group[:opacity], paths: paths }
    end
  end

  def self.strokes
    @strokes ||= compile
  end

  def self.visible_segments(time)
    result = []
    strokes.each do |group|
      group[:paths].each do |stroke|
        break if time <= stroke[:start]
        if time >= stroke[:start] + stroke[:duration] - 0.00000001
          stroke[:segments].each { |segment| result << segment[:output] }
          next
        end
        fraction = [[(time - stroke[:start]) / stroke[:duration], 0.0].max, 1.0].min
        remaining = stroke[:length] * fraction
        stroke[:segments].each do |segment|
          break if remaining <= 0
          length = segment[:length]
          next if length <= 0
          if remaining >= length
            result << segment[:output]
          else
            a, b = segment[:a], segment[:b]
            f = remaining / length
            result << [a, [a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f], stroke[:opacity]]
          end
          remaining -= length
        end
      end
    end
    result
  end

  def self.visible_native_lines(time)
    result = []
    strokes.each do |group|
      group[:paths].each do |stroke|
        break if time <= stroke[:start]
        if time >= stroke[:start] + stroke[:duration] - 0.00000001
          result.concat(stroke[:native])
          next
        end
        remaining = stroke[:length] * (time - stroke[:start]) / stroke[:duration]
        stroke[:segments].each do |segment|
          break if remaining <= 0
          length = segment[:length]
          next if length <= 0
          if remaining >= length
            result.concat(segment[:native])
          else
            a, b = segment[:a], segment[:b]
            fraction = remaining / length
            tip = [a[0] + (b[0] - a[0]) * fraction, a[1] + (b[1] - a[1]) * fraction]
            result.concat(native_lines(a, tip, stroke[:opacity]))
          end
          remaining -= length
        end
      end
    end
    result
  end

  def self.photo_alpha(time)
    ramp(time, 8.0, 18.0)
  end

  def self.pencil_alpha(time)
    1.0 - ramp(time, 12.0, 18.5)
  end

  def self.draw_pencil(args, time, camera)
    # Reuse the completed native render target during the long development.
    # Nothing is loaded from a raster sketch, and the full drawing is rebuilt
    # progressively on every loop. Only completed strokes reuse their geometry.
    @drawing_complete = false if time < 8.5
    return :nanhu_pencil if @drawing_complete
    pencil = args.outputs[:nanhu_pencil]
    pencil.w = 1608
    pencil.h = 1440
    pencil.background_color = [255, 255, 255, 0]
    # Completed segments reuse immutable line primitives; only the moving pen
    # tip allocates new geometry. This matters with thousands of fine details.
    pencil.primitives << visible_native_lines(time)
    @drawing_complete = true if time >= 8.5
    :nanhu_pencil
  end

  def self.render(args, time)
    target = args.outputs[:nanhu_opening]
    target.w = 1608
    target.h = 1440
    target.background_color = [255, 255, 255, 255]
    camera = crop(time)
    photographic_opacity = photo_alpha(time)
    if photographic_opacity > 0
      target.primitives << { x: 0, y: 0, w: 1608, h: 1440,
        path: LobbyConfig::PROJECTS[0][:image], a: (255 * photographic_opacity).round,
        source_x: camera[:x], source_y: camera[:y], source_w: camera[:w], source_h: camera[:h] }.sprite!
    end
    pencil_opacity = pencil_alpha(time)
    if pencil_opacity > 0
      pencil = draw_pencil(args, time, camera)
      target.primitives << { x: 0, y: 0, w: 1608, h: 1440, path: pencil,
        a: (255 * pencil_opacity).round }.sprite!
    end
    :nanhu_opening
  end
end
