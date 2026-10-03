# frozen_string_literal: true
require 'app/config.rb'
require 'app/timeline.rb'
require 'app/nanhu_sketch.rb'

class TianhuaLobby
  INK = [24, 37, 39]
  PAPER = [241, 239, 232]
  WHITE = [255, 255, 255]
  ACCENT = [164, 174, 140]

  def tick(args)
    unless @ready
      args.gtk.set_window_title 'TIANHUA | Reception Display'
      args.gtk.set_window_fullscreen LobbyConfig::FULLSCREEN
      args.gtk.hide_cursor
      @started_at = Time.now.to_f
      @qa = args.gtk.read_file('qa/enabled.txt')
      @captured = {}
      @last_frame = @started_at
      @last_capture = -10.0
      @max_frame_gap = 0.0
      @frame_gaps = []
      @ready = true
    end
    seconds = [Time.now.to_f - @started_at, 0.0].max
    timeline = LobbyTimeline.at(seconds, LobbyConfig::SCENES, LobbyConfig::CROSSFADE)
    current = LobbyConfig::SCENES[timeline[:index]]
    draw_scene(args, :current_scene, current, timeline[:progress])
    args.outputs.background_color = INK
    args.outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: :current_scene }
    if timeline[:mix] > 0
      upcoming = LobbyConfig::SCENES[timeline[:next_index]]
      draw_scene(args, :next_scene, upcoming, 0.0)
      args.outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: :next_scene, a: (255 * timeline[:mix]).round }
    end
    if @qa
      # Keep the optional QA hook safe when code is hot-reloaded mid-loop.
      @last_capture ||= -10.0
      now = Time.now.to_f
      if seconds > 3 && seconds - @last_capture > 1.0
        gap = now - @last_frame
        @max_frame_gap = [@max_frame_gap, gap].max
        @frame_gaps ||= []
        @frame_gaps << gap unless @qa_complete
      end
      @last_frame = now
      if timeline[:index] == 0
        [0.3, 2.5, 5.0, 8.0, 10.0, 13.0, 16.0, 18.5].each do |stage|
          key = "opening-#{stage}"
          if timeline[:elapsed] >= stage && !@captured[key]
            @captured[key] = true
            @last_capture = seconds
            args.outputs.screenshots << { x: 0, y: 0, w: 1280, h: 720, path: "qa/#{key}.png" }
          end
        end
      end
      key = timeline[:index]
      if timeline[:elapsed] > 3 && !@captured[key]
        @captured[key] = true
        @last_capture = seconds
        args.outputs.screenshots << { x: 0, y: 0, w: 1280, h: 720, path: "qa/scene-#{key}.png" }
      end
      if seconds > LobbyTimeline.duration(LobbyConfig::SCENES) + 3 && !@qa_complete
        p95 = @frame_gaps.sort[(@frame_gaps.length * 0.95).floor] || 0.0
        args.gtk.write_file('qa/result.txt', "Full loop complete. Captured #{@captured.keys.count { |key| key.is_a?(Integer) }} scenes and opening stages. Max frame gap after warm-up, excluding capture I/O: #{@max_frame_gap.round(4)} seconds. P95 frame gap: #{p95.round(4)} seconds.\n")
        @qa_complete = true
      end
    end
    # No visitor controls; OS window close/Alt+F4 is the operator exit.
  end

  def solid(out, x, y, w, h, color, alpha = 255)
    out.primitives << { x: x, y: y, w: w, h: h, r: color[0], g: color[1], b: color[2], a: alpha, path: 'assets/brand/pixel.png' }.sprite!
  end

  def label(out, text, x, y, size, color = WHITE, alpha = 255)
    # Calibrated visual size for Noto CJK in HD render targets, verified natively.
    out.primitives << { x: x, y: y, text: text, size_px: (size * 1.45).round,
      font: LobbyConfig::FONT, r: color[0], g: color[1], b: color[2], a: alpha, anchor_y: 0 }.label!
  end

  def logo(out, x, y, width, light = false, alpha = 255)
    out.primitives << { x: x, y: y, w: width, h: width * 130.0 / 1157,
      path: light ? 'assets/brand/logo-white.png' : 'assets/brand/logo.png', a: alpha }.sprite!
  end

  def photo(out, path, x, y, w, h, progress, iw = 1920.0, ih = 968.0)
    # Source cropping fills each viewport without stretching or letterboxes.
    zoom = 1.015 + 0.035 * progress
    scale = [w / iw, h / ih].max * zoom
    sw = w / scale
    sh = h / scale
    sx = (iw - sw) * (0.46 + 0.08 * progress)
    sy = (ih - sh) * 0.52
    out.primitives << { x: x, y: y, w: w, h: h, path: path,
      source_x: sx, source_y: sy, source_w: sw, source_h: sh }.sprite!
  end

  def draw_scene(args, name, scene, progress)
    out = args.outputs[name]
    out.w = 1280
    out.h = 720
    out.background_color = PAPER
    case scene[:kind]
    when :welcome then welcome(args, out, progress)
    when :hero then hero(out, scene[:project], progress)
    when :collection then collection(out, progress)
    end
  end

  def welcome(args, out, progress)
    time = progress * LobbyConfig::SCENES[0][:duration]
    # A real blank sheet at t=0; the photo is absent for the first 8 seconds.
    solid(out, 0, 0, 1280, 720, WHITE)
    sketch = NanhuSketch.render(args, time)
    out.primitives << { x: 476, y: 0, w: 804, h: 720, path: sketch }.sprite!
    brand = (255 * NanhuSketch.ramp(time, 1.2, 3.0)).round
    introduction = (255 * NanhuSketch.ramp(time, 3.0, 5.0)).round
    detail = (255 * NanhuSketch.ramp(time, 5.0, 7.0)).round
    caption = (255 * NanhuSketch.ramp(time, 17.5, 19.0)).round
    logo(out, 64, 612, 310, false, brand)
    solid(out, 64, 545, 42, 2, INK, introduction)
    label(out, '欢迎来到天华', 60, 375, 48, INK, introduction)
    label(out, 'WELCOME TO', 64, 329, 20, INK, introduction)
    label(out, 'TIANHUA', 60, 263, 58, INK, introduction)
    label(out, '建筑  ·  室内  ·  规划  ·  景观', 64, 137, 19, INK, detail)
    label(out, '上海天华建筑设计有限公司', 64, 99, 15, INK, detail)
    label(out, '嘉兴南湖天地', 522, 62, 22, WHITE, caption)
    label(out, 'JIAXING NANHU PLACE', 522, 38, 12, WHITE, caption)
    solid(out, 64, 61, 42 + progress * 290, 2, ACCENT, detail)
  end

  def hero(out, index, progress)
    p = LobbyConfig::PROJECTS[index]
    photo(out, p[:image], 0, 0, 1280, 720, progress)
    out.primitives << { x: 0, y: 0, w: 1280, h: 720, path: 'assets/brand/hero-shade.png' }.sprite!
    logo(out, 64, 616, 280, true)
    label(out, 'SELECTED WORKS', 1023, 635, 14)
    solid(out, 64, 206, 42, 2, ACCENT)
    label(out, p[:title], 60, 129, 44)
    label(out, p[:english], 64, 93, 18)
    label(out, 'TIANHUA  /  天华', 64, 47, 12)
    label(out, format('%02d', index + 1), 1127, 88, 38)
    label(out, '/ 06', 1180, 94, 14)
    6.times do |n|
      solid(out, 1074 + n * 24, 58, 16, 2, WHITE, n == index ? 255 : 75)
    end
    solid(out, 64, 33, 1152 * progress, 1, WHITE, 80)
  end

  def collection(out, progress)
    solid(out, 0, 0, 1280, 720, PAPER)
    logo(out, 64, 626, 262)
    label(out, '作品选集', 62, 533, 40, INK)
    label(out, 'SELECTED WORKS', 65, 504, 15, INK)
    solid(out, 64, 476, 1152, 1, [199, 201, 191])
    cards = [
      ['assets/photos/collection-01.jpg', '居住', '重庆香港置地天湖岛'],
      ['assets/photos/collection-02.jpg', '商务办公 / 产业办公', '剑桥大学南京科技创新中心'],
      ['assets/photos/collection-03.jpg', '旅居 / 酒店', '长泰福隆·心乡谷']
    ]
    cards.each_with_index do |card, i|
      x = 64 + i * 390
      photo(out, card[0], x, 198, 372, 248, progress, i == 1 ? 1794.0 : 880.0, 880.0)
      label(out, card[1], x, 158, 15, INK)
      label(out, card[2], x, 120, 23, INK)
    end
    label(out, '建筑  ·  室内  ·  规划  ·  景观  ·  审图  ·  技术咨询  ·  可持续', 64, 53, 15, INK)
    label(out, 'TIANHUA', 1117, 53, 15, INK)
  end
end

def tick(args)
  $lobby ||= TianhuaLobby.new
  $lobby.tick(args)
end
