# frozen_string_literal: true
# Selected details observed in assets/photos/hero-01.jpg (1920 x 968).
# Coordinates are SOURCE pixels, top-left origin. No image-wide edge filter.
# Each quadrilateral is [ridge left, ridge right, eave right, eave left].
# Interpolated tile rhythms describe those specific visible planes, rather than
# claiming to trace every tile in this dusk photograph. Keep these editable.
module NanhuArchitectureDetail
  # [four plane corners, number of longitudinal seams, transverse courses]
  ROOF_PLANES = [
    # Western procession of gabled halls, from foreground toward the north.
    [[[435,615],[537,640],[552,657],[448,682]],18,4],
    [[[413,589],[457,568],[478,587],[443,606]],10,3],
    [[[451,529],[505,545],[529,560],[482,550]],10,3],
    [[[438,497],[480,507],[506,519],[456,514]],9,2],
    [[[439,464],[475,476],[491,488],[450,481]],8,2],
    # Three separate roof bays along the northern side of the western court.
    [[[471,415],[501,408],[539,418],[531,434]],10,3],
    [[[545,417],[579,413],[593,418],[579,435]],9,3],
    [[[600,419],[619,420],[623,425],[606,438]],6,2],
    # Central long hall; inset slightly from silhouette to preserve the eave.
    [[[556,520],[672,492],[703,517],[578,546]],24,5],
    [[[539,484],[622,463],[647,480],[552,505]],18,3],
    # Two intermediate gables and the broad southeast hall.
    [[[641,442],[679,420],[705,441],[665,462]],10,3],
    [[[705,473],[740,452],[764,474],[730,491]],10,3],
    [[[772,510],[809,486],[852,518],[810,572]],16,5],
    [[[855,522],[903,544],[915,559],[855,541]],11,3],
    # Northern gabled pavilion facing the central water court.
    [[[763,375],[813,361],[824,379],[791,404]],13,3],
    [[[813,361],[865,374],[882,386],[824,379]],12,2],
    [[[869,420],[911,406],[928,427],[906,443]],11,3]
  ]

  # Large saw-tooth hall in the northeast. Long, clearly separated dark strips
  # are roof standing seams, not a generalized hatch laid over the photograph.
  SHED_PLANES = [
    [[[934,353],[950,349],[1005,414],[992,420]],5,0],
    [[[958,347],[972,344],[1031,403],[1018,407]],5,0],
    [[[985,342],[998,340],[1056,397],[1043,400]],5,0],
    [[[1040,388],[1066,383],[1128,404],[1103,409]],6,2],
    [[[1074,382],[1103,379],[1162,398],[1135,403]],6,2],
    [[[1110,377],[1140,374],[1195,390],[1169,397]],6,2]
  ]

  # [top-left, top-right, bottom-right, bottom-left, bay count]. Visible
  # elevations only: leave the tree-obscured southern edge of the courts quiet.
  FACADES = [
    [[401,674],[447,690],[449,710],[404,695],5],
    [[449,691],[553,660],[552,679],[450,711],10],
    [[580,551],[704,521],[703,539],[582,569],12],
    [[770,550],[808,578],[811,599],[775,574],5],
    [[812,578],[851,549],[852,586],[815,599],5],
    [[855,548],[919,565],[919,579],[856,589],6],
    [[794,410],[822,420],[823,435],[796,426],4],
    [[824,420],[868,406],[869,420],[825,435],6],
    [[918,449],[947,456],[949,470],[921,465],4],
    [[950,455],[970,441],[970,455],[952,470],3],
    [[1069,433],[1090,440],[1090,454],[1069,448],3],
    [[1094,440],[1110,433],[1110,445],[1094,454],2],
    [[630,374],[655,381],[656,390],[631,384],4],
    [[658,379],[685,369],[687,379],[659,390],4],
    [[694,356],[715,364],[716,376],[695,367],3],
    [[719,361],[744,352],[745,365],[720,375],4],
    [[751,340],[775,348],[776,360],[752,351],3],
    [[779,347],[802,339],[803,352],[780,360],3]
  ]

  # Double contours are small physical fascia/parapet offsets, never a global
  # duplicate of the complete building. Their bends follow the original eaves.
  EAVES = [
    [[390,648],[401,678],[449,695],[554,663]],
    [[391,651],[402,681],[449,698],[554,666]],
    [[411,592],[445,609],[479,592],[540,608]],
    [[407,555],[433,571],[482,552],[532,567]],
    [[402,518],[415,532],[456,516],[510,525]],
    [[402,484],[417,499],[450,482],[493,495]],
    [[472,441],[531,442],[578,443],[608,445],[625,429]],
    [[538,489],[551,513],[652,483]],
    [[556,524],[576,554],[707,522]],
    [[579,558],[705,527]],
    [[642,446],[666,469],[707,449],[753,453]],
    [[704,477],[730,499],[766,480],[808,486]],
    [[764,530],[770,551],[810,583],[854,550],[921,567]],
    [[773,555],[811,586],[854,554],[919,571]],
    [[759,395],[792,413],[824,386],[885,393]],
    [[869,424],[908,451],[929,434],[970,442]],
    [[932,357],[993,422],[1011,432]],
    [[1041,392],[1100,414],[1112,433]],
    [[1074,386],[1130,409],[1142,425]],
    [[1110,382],[1166,404],[1177,421]],
    [[1147,377],[1197,393],[1212,411]]
  ]

  # Foreground white museum/pavilion: stepped flat roof plates, returns, roof
  # lips, recessed glazing. These are hand placed, not inferred roof hatching.
  WHITE_PAVILION = [
    [[481,716],[495,705],[499,738],[484,748],[481,716]],
    [[486,754],[491,780],[504,776]],
    [[539,703],[548,699],[553,722],[548,727],[539,703]],
    [[560,707],[610,695],[642,708],[616,717],[560,707]],
    [[565,712],[610,699],[635,709],[616,714]],
    [[564,725],[613,737],[644,720]],
    [[573,731],[573,717]],[[614,738],[614,722]],
    [[505,758],[525,754],[537,780],[507,787],[505,758]],
    [[509,761],[523,758],[531,777],[510,782],[509,761]],
    [[545,783],[580,777],[590,803],[559,813],[545,783]],
    [[550,786],[577,781],[585,800],[561,808],[550,786]],
    [[559,813],[565,831],[603,823],[602,801]],
    [[566,817],[571,825],[597,819],[597,808]],
    [[591,765],[613,752],[650,761],[660,783],[636,797],[604,790]],
    [[598,767],[616,758],[646,766],[653,782],[635,791],[607,786],[598,767]],
    [[614,799],[615,819],[641,824],[666,810],[666,788]],
    [[620,801],[620,815],[640,819],[661,807],[661,795]],
    [[642,824],[642,805]],[[639,819],[639,807]],
    [[564,835],[566,849],[603,839],[603,829]],
    [[570,837],[572,843],[597,837],[597,832]],
    [[511,792],[519,827],[532,825],[527,789]],
    [[515,797],[520,821],[526,820],[522,795]],
    # Narrow glazed connector behind the roof plates.
    [[558,738],[578,733],[612,731],[668,714],[723,708]],
    [[576,748],[617,744],[674,728],[724,720]],
    [[590,735],[593,746]],[[604,733],[607,744]],
    [[622,730],[625,740]],[[637,725],[640,736]],
    [[652,721],[655,732]],[[668,717],[671,728]],
    [[685,714],[688,724]],[[702,711],[705,722]],
    [[614,704],[617,702],[620,704],[617,706],[614,704]],
    [[542,791],[545,789],[548,791],[545,793],[542,791]],
    [[574,796],[577,794],[580,796],[577,798],[574,796]],
    [[629,772],[632,770],[635,772],[632,774],[629,772]]
  ]

  # Small courtyard houses in the foreground center, with their characteristic
  # stepped white fire walls and inward-facing roof courts.
  COURTYARDS = [
    [[594,591],[625,580],[651,585],[658,599],[645,605]],
    [[599,592],[625,584],[646,588],[650,598],[636,601]],
    [[595,598],[599,619],[615,632]],
    [[625,615],[655,605],[678,612],[693,626],[677,632]],
    [[630,615],[656,609],[675,615],[684,625],[675,628]],
    [[620,623],[639,618],[648,634],[636,637],[622,633]],
    [[661,649],[695,640],[720,646],[727,660],[699,675]],
    [[668,650],[695,644],[716,650],[721,659],[700,669]],
    [[676,596],[712,583],[743,591],[745,601],[728,608]],
    [[684,595],[713,587],[738,594],[739,600],[727,604]],
    [[610,631],[615,629],[621,641],[631,644],[635,654]],
    [[641,645],[646,641],[652,656],[663,660],[668,672]],
    [[672,661],[677,657],[683,671],[697,676]],
    [[595,616],[600,614],[606,626],[614,629]],
    [[611,644],[615,662],[621,677]],
    [[616,645],[620,660],[626,676]],
    [[625,678],[642,683],[660,687]],
    [[636,644],[640,659]],[[641,646],[645,661]],
    [[650,661],[655,678]],[[655,663],[660,680]],
    [[668,675],[674,691]],[[674,677],[680,693]],
    [[681,693],[695,697],[710,691]],
    # The open pedestrian court, with a few real linear paving/step edges.
    [[554,574],[562,597],[574,630],[582,659],[598,682]],
    [[560,573],[569,596],[581,628],[588,657],[603,678]],
    [[718,551],[737,564],[757,577]],
    [[722,548],[740,561],[760,574]],
    [[732,594],[749,613],[770,624]],
    [[736,592],[753,610],[773,621]],
    [[464,701],[483,695],[503,689],[523,683]],
    [[466,705],[486,699],[506,693],[526,687]]
  ]

  # Rear shop row: the two visible faces of each existing box-like volume.
  # Recessed frames stop inside their existing parapet outlines.
  REAR_SHOP_FACES = [
    [[919,317],[939,325],[940,340],[922,332]],
    [[942,325],[961,316],[961,329],[943,339]],
    [[970,303],[991,313],[992,333],[972,323]],
    [[995,313],[1018,304],[1018,320],[995,333]],
    [[1048,304],[1073,314],[1074,329],[1049,318]],
    [[1077,313],[1099,303],[1099,318],[1077,329]],
    [[1120,296],[1144,305],[1145,321],[1121,309]],
    [[1149,305],[1170,296],[1170,310],[1149,322]]
  ]

  # Pixel-checked tower bands. The fourth rear tower is partly occluded and
  # dark: only its visible upper strip is described, never bands through trees.
  # [left upper, center upper, right upper, vertical extent, visible floors]
  TOWER_BANDS = [
    [[1008,155],[1017,158],[1028,155],43,10],
    [[1048,166],[1057,169],[1070,165],35,8],
    [[1118,166],[1128,169],[1142,164],38,9],
    [[1107,141],[1115,143],[1123,139],12,3]
  ]

  def self.rear_details
    shop_frames = []
    quiet_windows = []
    REAR_SHOP_FACES.each do |quad|
      shop_frames << [plane_point(quad, 0.07, 0.07),
                      plane_point(quad, 0.93, 0.07)]
      shop_frames << [plane_point(quad, 0.15, 0.22),
                      plane_point(quad, 0.85, 0.22),
                      plane_point(quad, 0.85, 0.86),
                      plane_point(quad, 0.15, 0.86),
                      plane_point(quad, 0.15, 0.22)]
      [0.42, 0.66].each do |v|
        quiet_windows << [plane_point(quad, 0.17, v),
                          plane_point(quad, 0.83, v)]
      end
      [0.33, 0.51, 0.69].each do |u|
        quiet_windows << [plane_point(quad, u, 0.24),
                          plane_point(quad, u, 0.83)]
      end
    end
    tower_floors = []
    TOWER_BANDS.each do |tower|
      left, center, right, height, floors = tower
      (0...floors).each do |i|
        dy = height * i.to_f / floors
        tower_floors << [[left[0], left[1] + dy],
                        [center[0], center[1] + dy],
                        [right[0], right[1] + dy]]
        # Small dark recessed slots under each photographed white balcony band.
        [0.24, 0.52, 0.80].each do |u|
          a = mix(left, right, u)
          bend = u < 0.5 ? u * 2 : (1 - u) * 2
          y = a[1] + dy + bend * 2.4 + 1.0
          quiet_windows << [[a[0], y], [a[0], y + 1.7]]
        end
      end
    end
    [shop_frames, quiet_windows, tower_floors]
  end

  def self.mix(a, b, t)
    [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t]
  end

  def self.plane_point(quad, u, v)
    mix(mix(quad[0], quad[1], u), mix(quad[3], quad[2], u), v)
  end

  def self.roof_details(planes)
    seams = []
    courses = []
    planes.each do |plane|
      quad, count, rows = plane
      # Inset endpoints keep tile lines from overshooting the roof silhouette.
      (1...count).each do |i|
        u = i.to_f / count
        seams << [plane_point(quad, u, 0.04), plane_point(quad, u, 0.96)]
      end
      (1..rows).each do |i|
        v = i.to_f / (rows + 1)
        courses << [plane_point(quad, 0.025, v), plane_point(quad, 0.975, v)]
      end
    end
    [seams, courses]
  end

  def self.facade_details
    columns = []
    glazing = []
    FACADES.each do |face|
      quad = face[0, 4]
      bays = face[4]
      # A sill and transom follow each actual facade's perspective.
      [0.18, 0.56, 0.90].each do |v|
        glazing << [plane_point(quad, 0.02, v), plane_point(quad, 0.98, v)]
      end
      (1...bays).each do |i|
        u = i.to_f / bays
        columns << [plane_point(quad, u, 0.03), plane_point(quad, u, 0.97)]
      end
      (0...bays).each do |i|
        # A recessed glazing jamb per bay, not invented freestanding windows.
        u = (i + 0.22) / bays
        glazing << [plane_point(quad, u, 0.23), plane_point(quad, u, 0.84)]
      end
    end
    [columns, glazing]
  end

  def self.groups
    return @groups if @groups
    seams, courses = roof_details(ROOF_PLANES)
    shed_seams, shed_courses = roof_details(SHED_PLANES)
    columns, glazing = facade_details
    rear_frames, rear_windows, tower_floors = rear_details
    @groups = [
      { start: 2.2, finish: 7.5, opacity: 144, paths: EAVES },
      { start: 2.5, finish: 7.7, opacity: 94, paths: seams },
      { start: 2.9, finish: 7.9, opacity: 72, paths: courses },
      { start: 3.0, finish: 7.8, opacity: 110, paths: shed_seams },
      { start: 3.3, finish: 8.0, opacity: 76, paths: shed_courses },
      { start: 3.5, finish: 8.1, opacity: 142, paths: columns },
      { start: 3.9, finish: 8.3, opacity: 101, paths: glazing },
      { start: 4.3, finish: 8.4, opacity: 148, paths: WHITE_PAVILION },
      { start: 4.7, finish: 8.5, opacity: 124, paths: COURTYARDS },
      { start: 4.1, finish: 8.5, opacity: 102, paths: rear_frames },
      { start: 4.5, finish: 8.5, opacity: 62, paths: rear_windows },
      { start: 4.8, finish: 8.5, opacity: 80, paths: tower_floors }
    ]
  end
end
