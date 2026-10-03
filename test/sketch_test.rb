# frozen_string_literal: true
require 'minitest/autorun'
$LOAD_PATH.unshift File.expand_path('..', __dir__)
require 'app/config'
require 'app/nanhu_sketch'

class SketchTest < Minitest::Test
  def test_opening_begins_without_any_strokes_or_photograph
    [0, 0.3, 0.64].each { |t| assert_empty NanhuSketch.visible_segments(t) }
    assert_equal 0.0, NanhuSketch.photo_alpha(7.99)
    assert_equal 1.0, NanhuSketch.photo_alpha(18.0)
  end

  def test_drawing_progresses_by_distance_and_finishes_before_photo
    previous = 0.0
    86.times do |n|
      segments = NanhuSketch.visible_segments(n / 10.0)
      length = segments.sum { |a, b, _| Math.sqrt((b[0] - a[0])**2 + (b[1] - a[1])**2) }
      assert_operator length + 0.00001, :>=, previous
      previous = length
    end
    assert_equal NanhuSketch.visible_segments(8.5), NanhuSketch.visible_segments(10.0)
    assert_operator NanhuSketch.visible_segments(8.5).length, :>, 4000
  end

  def test_camera_is_locked_during_the_entire_sketch_photo_transition
    [0, 3, 6, 8.5, 10, 13, 16, 18.5].each do |time|
      assert_equal NanhuSketch.crop(0), NanhuSketch.crop(time)
    end
    assert_operator NanhuSketch.crop(21)[:scale], :>, NanhuSketch.crop(18.5)[:scale]
  end

  def test_photo_space_and_vector_space_have_identical_corners
    crop = NanhuSketch.crop(13.0)
    bottom_left = NanhuSketch.point([crop[:x], 968 - crop[:y]], crop)
    top_right = NanhuSketch.point([crop[:x] + crop[:w], 968 - crop[:y] - crop[:h]], crop)
    assert_in_delta 0, bottom_left[0], 0.000001
    assert_in_delta 0, bottom_left[1], 0.000001
    assert_in_delta 804, top_right[0], 0.000001
    assert_in_delta 720, top_right[1], 0.000001
  end

  def test_photographic_development_is_slow_continuous_and_monotonic
    previous = 0.0
    1261.times do |frame|
      alpha = NanhuSketch.photo_alpha(frame / 60.0)
      assert_operator alpha, :>=, previous
      assert_operator alpha - previous, :<=, 0.00251
      previous = alpha
    end
    assert_equal 1.0, NanhuSketch.pencil_alpha(12.0)
    assert_equal 0.0, NanhuSketch.pencil_alpha(18.5)
  end

  def test_interpolated_curves_preserve_source_landmarks
    NanhuCurves::WATERFRONT.each do |points|
      curve = NanhuCurves.interpolate(points)
      assert_equal points.first, curve.first
      assert_equal points.last, curve.last
      assert_operator curve.length, :>, points.length * 2
      curve.each { |p| assert p.all? { |v| v.finite? } }
    end
  end

  def test_every_stroke_has_positive_duration_and_finite_source_coordinates
    NanhuSketch.strokes.each do |group|
      group[:paths].each do |stroke|
        assert_operator stroke[:duration], :>, 0
        stroke[:points].each { |point| point.each { |coordinate| assert coordinate.finite? } }
      end
    end
  end
end
