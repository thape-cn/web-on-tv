# frozen_string_literal: true
# Editable photo-space control points for genuinely curved site features.
# Architectural eaves and masonry retain straight edges in the other modules.
module NanhuCurves
  WATERFRONT = [
    [[394,917],[530,892],[650,866],[797,830],[933,785],[1046,747],[1156,706]],
    [[395,929],[538,902],[655,877],[803,841],[941,796],[1051,757],[1158,717]],
    [[1149,688],[1162,677],[1165,662],[1159,652]],
    [[1159,613],[1191,628],[1239,635],[1282,627],[1314,613],[1348,589],[1380,563],[1438,526]],
    [[1122,603],[1147,617],[1186,634],[1237,642],[1283,634],[1316,620],[1352,597]],
    [[506,877],[554,867],[650,845],[746,821],[816,797]]
  ]

  # Smooth interpolating curves: every landmark is preserved, and the sampled
  # path is drawn by distance using the same native line renderer as the roofs.
  def self.interpolate(points, closed = false)
    result = []
    count = closed ? points.length : points.length - 1
    count.times do |i|
      p0 = points[closed ? (i - 1) % points.length : [i - 1, 0].max]
      p1 = points[i]
      p2 = points[(i + 1) % points.length]
      p3 = points[closed ? (i + 2) % points.length : [i + 2, points.length - 1].min]
      distance = Math.sqrt((p2[0] - p1[0])**2 + (p2[1] - p1[1])**2)
      steps = [(distance / 2.2).ceil, 4].max
      steps.times do |step|
        t = step.to_f / steps
        t2 = t * t
        t3 = t2 * t
        result << 2.times.map do |axis|
          0.5 * ((2 * p1[axis]) + (-p0[axis] + p2[axis]) * t +
            (2 * p0[axis] - 5 * p1[axis] + 4 * p2[axis] - p3[axis]) * t2 +
            (-p0[axis] + 3 * p1[axis] - 3 * p2[axis] + p3[axis]) * t3)
        end
      end
    end
    result << (closed ? points.first.dup : points.last.dup)
    result
  end

  def self.groups
    contour = WATERFRONT.map { |points| interpolate(points) }
    crowns = []
    inner_crowns = []
    NanhuStrokes::TREES.each_with_index do |tree, index|
      cx, cy, radius = tree
      # Low-frequency contours create soft, unequal natural crowns. The old
      # uniform spiky polygon stamps are deliberately not retained.
      controls = 15.times.map do |n|
        angle = n * Math::PI * 2 / 15
        extent = 1.0 + 0.17 * Math.sin(angle * 3 + index * 1.37) +
          0.10 * Math.cos(angle * 5 + index * 0.71)
        [cx + Math.cos(angle) * radius * extent,
         cy + Math.sin(angle) * radius * (0.61 + index % 3 * 0.04) * extent]
      end
      crowns << interpolate(controls, true)
      2.times do |layer|
        offset = (layer - 0.5) * radius * 0.65
        inner_crowns << interpolate([
          [cx - radius * 0.52, cy + offset],
          [cx - radius * 0.28, cy + offset - radius * 0.22],
          [cx + radius * 0.08, cy + offset - radius * 0.08],
          [cx + radius * 0.32, cy + offset - radius * 0.24],
          [cx + radius * 0.51, cy + offset]
        ])
      end
    end
    # The broad planted banks connect the individual crowns into the real
    # waterfront's landscape mass, rather than isolated plan-view symbols.
    banks = [
      [[687,777],[714,759],[746,766],[770,738],[798,741],[829,712],[851,721],[881,693],[910,700],[941,676],[967,680],[1000,657],[1032,669],[1062,648],[1098,656]],
      [[1111,599],[1141,576],[1172,581],[1201,552],[1234,554],[1261,527],[1282,530],[1310,505],[1340,502],[1360,478],[1387,475],[1416,451]]
    ].map { |points| interpolate(points) }
    [
      { start: 0.65, finish: 3.0, opacity: 180, paths: contour },
      { start: 4.4, finish: 8.0, opacity: 74, paths: crowns + banks },
      { start: 5.2, finish: 8.4, opacity: 39, paths: inner_crowns }
    ]
  end
end
