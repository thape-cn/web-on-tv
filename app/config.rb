# frozen_string_literal: true
module LobbyConfig
  WIDTH = 1280
  HEIGHT = 720
  FULLSCREEN = true
  CROSSFADE = 2.0
  FONT = 'assets/fonts/TianhuaDisplaySans.otf'
  PROJECTS = [
    { title: '嘉兴南湖天地', english: 'JIAXING NANHU PLACE', image: 'assets/photos/hero-01.jpg', url: 'https://www.thape.com/works/273' },
    { title: '南昌新力中心', english: 'NANCHANG SINIC CENTER', image: 'assets/photos/hero-02.jpg', url: 'https://www.thape.com/works/28' },
    { title: '温州和晟温德姆酒店', english: 'WENZHOU WYNDHAM HOTEL', image: 'assets/photos/hero-03.jpg', url: 'https://www.thape.com/works/48' },
    { title: '上海碧云国际社区碧云尊邸', english: 'SHANGHAI GREEN RESIDENCE', image: 'assets/photos/hero-04.jpg', url: 'https://www.thape.com/works/145' },
    { title: '上海瑞安新天地广场', english: 'SHANGHAI SHUI ON XINTIANDI', image: 'assets/photos/hero-05.jpg', url: 'https://www.thape.com/works/54' },
    { title: '苏州高新区文体中心', english: 'SND CULTURAL & SPORTS CENTRE', image: 'assets/photos/hero-06.jpg', url: 'https://www.thape.com/works/39' }
  ]
  SCENES = [
    { kind: :welcome, duration: 21.0 },
    { kind: :hero, project: 0, duration: 14.0 },
    { kind: :hero, project: 1, duration: 14.0 },
    { kind: :hero, project: 2, duration: 14.0 },
    { kind: :collection, duration: 12.0 },
    { kind: :hero, project: 3, duration: 14.0 },
    { kind: :hero, project: 4, duration: 14.0 },
    { kind: :hero, project: 5, duration: 14.0 }
  ]
end
