# frozen_string_literal: true
require 'app/nanhu_strokes.rb'

# A distance-revealed vector drawing, not a raster sketch effect. All strokes
# live in the original photograph's coordinates and share its camera transform.
module NanhuSketch
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
    zoom = 1.015 + 0.010 * ramp(time, 27.0, 34.0)
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

  def self.compile
    groups = NanhuStrokes::GROUPS.map do |group|
      { start: group[:start], finish: group[:finish], opacity: group[:opacity], paths: group[:paths].map { |p| p.map { |xy| xy.dup } } }
    end
    planting = NanhuStrokes::TREES.each_with_index.map do |tree, index|
      cx, cy, radius = tree
      33.times.map do |n|
        angle = n * Math::PI * 2 / 32
        variation = 1.0 + 0.14 * Math.sin(n * 2.3 + index) + 0.07 * Math.sin(n * 0.7 + index * 2)
        [cx + Math.cos(angle) * radius * variation,
         cy + Math.sin(angle) * radius * 0.67 * variation]
      end
    end
    groups << { start: 13.4, finish: 18.5, opacity: 52, paths: planting }
    # Light parallel roof pencil-work, limited to known roof planes.
    hatches = []
    [ [[554,520],[667,492],[571,544],[695,515],12],
      [[388,645],[434,617],[400,667],[446,639],8],
      [[773,517],[808,490],[802,557],[838,531],8],
      [[1031,355],[1138,349],[1079,375],[1185,367],11] ].each do |plane|
      a, b, c, d, count = plane
      count.times do |i|
        f = (i + 1).to_f / (count + 1)
        hatches << [[a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f],
                    [c[0] + (d[0] - c[0]) * f, c[1] + (d[1] - c[1]) * f]]
      end
    end
    groups << { start: 12.0, finish: 18.2, opacity: 72, paths: hatches }
    # Perspective-aligned mullions and roof seams suggest material, without
    # tracing every photographic texture or inventing a noisy edge field.
    details = []
    [ [[580,551],[704,521],[581,568],[704,539],18],
      [[812,579],[921,564],[813,598],[921,579],16],
      [[769,549],[809,577],[773,571],[812,598],6],
      [[450,692],[553,662],[450,708],[553,678],15],
      [[398,674],[446,691],[403,693],[449,707],7],
      [[1069,433],[1090,440],[1069,448],[1090,454],4],
      [[1125,433],[1141,426],[1125,446],[1141,440],3],
      [[1158,428],[1178,421],[1158,440],[1178,432],3],
      [[625,383],[656,391],[626,394],[656,403],6],
      [[658,392],[689,381],[658,403],[689,392],6],
      [[1016,158],[1039,155],[1017,209],[1040,208],4],
      [[1050,149],[1071,147],[1050,211],[1072,212],4]
    ].each do |plane|
      a, b, c, d, count = plane
      count.times do |i|
        f = (i + 1).to_f / (count + 1)
        details << [[a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f],
                    [c[0] + (d[0] - c[0]) * f, c[1] + (d[1] - c[1]) * f]]
      end
    end
    groups << { start: 14.1, finish: 19.0, opacity: 100, paths: details }
    groups.map do |group|
      lengths = group[:paths].map do |path|
        path.each_cons(2).map { |a, b| Math.sqrt((b[0] - a[0])**2 + (b[1] - a[1])**2) }.inject(0.0, :+)
      end
      total = lengths.inject(0.0, :+)
      cursor = 0.0
      paths = group[:paths].each_with_index.map do |path, i|
        duration = (group[:finish] - group[:start]) * lengths[i] / total
        record = { points: path, length: lengths[i], start: group[:start] + cursor, duration: duration }
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
      group[:paths].each_with_index do |stroke, stroke_index|
        next if time <= stroke[:start]
        fraction = [[(time - stroke[:start]) / stroke[:duration], 0.0].max, 1.0].min
        remaining = stroke[:length] * fraction
        stroke[:points].each_cons(2) do |a, b|
          break if remaining <= 0
          length = Math.sqrt((b[0] - a[0])**2 + (b[1] - a[1])**2)
          next if length <= 0
          f = [remaining / length, 1.0].min
          result << [a, [a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f], group[:opacity] * (0.92 + 0.08 * Math.sin(stroke_index * 1.7))]
          remaining -= length
        end
      end
    end
    result
  end

  def self.render(args, time)
    target = args.outputs[:nanhu_opening]
    target.w = 1608
    target.h = 1440
    target.background_color = [255, 255, 255, 255]
    camera = crop(time)
    photo_alpha = ramp(time, 20.0, 27.0)
    if photo_alpha > 0
      target.primitives << { x: 0, y: 0, w: 1608, h: 1440,
        path: LobbyConfig::PROJECTS[0][:image], a: (255 * photo_alpha).round,
        source_x: camera[:x], source_y: camera[:y], source_w: camera[:w], source_h: camera[:h] }.sprite!
    end
    pencil_alpha = 1.0 - ramp(time, 21.5, 26.5)
    if pencil_alpha > 0
      visible_segments(time).each do |segment|
        a = point(segment[0], camera)
        b = point(segment[1], camera)
        # True line primitives at 2x resolution, linearly reduced by the
        # compositor. Two fine passes give calm graphite-like pressure and
        # remove 720p stair-stepping without rasterizing the drawing to a file.
        [0.0, 0.65].each do |offset|
          target.primitives << { x: a[0] * 2, y: a[1] * 2 + offset,
            x2: b[0] * 2, y2: b[1] * 2 + offset,
            r: 53, g: 65, b: 65, a: (segment[2] * pencil_alpha).round }.line!
        end
      end
    end
    :nanhu_opening
  end
end
