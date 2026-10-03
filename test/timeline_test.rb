# frozen_string_literal: true
require 'minitest/autorun'
require_relative '../app/config'
require_relative '../app/timeline'

class TimelineTest < Minitest::Test
  def test_total_duration
    assert_equal 117.0, LobbyTimeline.duration(LobbyConfig::SCENES)
  end

  def test_every_boundary_and_loop
    at = 0.0
    LobbyConfig::SCENES.each_with_index do |scene, index|
      state = LobbyTimeline.at(at, LobbyConfig::SCENES, LobbyConfig::CROSSFADE)
      assert_equal index, state[:index]
      assert_equal 0.0, state[:elapsed]
      at += scene[:duration]
      last = LobbyTimeline.at(at - 0.00001, LobbyConfig::SCENES, LobbyConfig::CROSSFADE)
      assert_equal index, last[:index]
      assert_in_delta 1.0, last[:mix], 0.00001
    end
    assert_equal 0, LobbyTimeline.at(at, LobbyConfig::SCENES, 2)[:index]
  end

  def test_long_running_deterministic_loop
    [0, 1, 10, 52, 64, 105.9].each do |t|
      base = LobbyTimeline.at(t, LobbyConfig::SCENES, 2)
      later = LobbyTimeline.at(t + 117 * 100_000, LobbyConfig::SCENES, 2)
      assert_equal base[:index], later[:index]
      assert_in_delta base[:mix], later[:mix], 0.000001
    end
  end

  def test_every_frame_is_bounded
    7021.times do |frame|
      state = LobbyTimeline.at(frame / 60.0, LobbyConfig::SCENES, 2)
      assert_operator state[:mix], :>=, 0
      assert_operator state[:mix], :<=, 1
      assert_operator state[:progress], :>=, 0
      assert_operator state[:progress], :<, 1
    end
  end

  def test_assets_present_and_no_runtime_dependency_in_content
    paths = LobbyConfig::PROJECTS.map { |p| p[:image] }
    paths += [LobbyConfig::FONT, 'assets/brand/logo.png', 'assets/brand/logo-white.png', 'assets/brand/hero-shade.png']
    paths.each { |path| assert File.file?(File.expand_path('../' + path, __dir__)), path }
    LobbyConfig::SCENES.each { |scene| assert_operator scene[:duration], :>, LobbyConfig::CROSSFADE }
  end
end
