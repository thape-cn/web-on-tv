# Asset provenance and rights

The nine photographs and six hero CN/EN title pairs below come from the supplied Tianhua homepage snapshot. Relative website paths resolve against `https://www.thape.com`. Work URLs are source references only; the app loads local files and makes no network requests.

## Photography

All listed photographs are Tianhua website content, **all rights reserved by Tianhua Architectural Design Co., Ltd**, according to the source repository's `LICENSE.md`. The website code's MIT license expressly excludes pictures, logos, news and other non-code content. Inclusion here does not grant a public redistribution license.

| Local path | Project | Relative website image path | Source work URL |
| --- | --- | --- | --- |
| `assets/photos/hero-01.jpg` | 嘉兴南湖天地 / JIAXING NANHU PLACE | `/uploads/tail_home/background_1/1/%E5%8D%97%E6%B9%961920x968.jpg` | https://www.thape.com/works/273 |
| `assets/photos/hero-02.jpg` | 南昌新力中心 / NANCHANG SINIC CENTER | `/uploads/tail_home/background_2/1/lunbo-1.jpg` | https://www.thape.com/works/28 |
| `assets/photos/hero-03.jpg` | 温州和晟温德姆酒店 / WENZHOU WYNDHAM HOTEL | `/uploads/tail_home/background_3/1/%E6%B8%A9%E5%BE%B7%E5%A7%861920x968.jpg` | https://www.thape.com/works/48 |
| `assets/photos/hero-04.jpg` | 上海碧云国际社区碧云尊邸 / SHANGHAI GREEN RESIDENCE | `/uploads/tail_home/background_4/1/%E7%A2%A7%E4%BA%911920x968.jpg` | https://www.thape.com/works/145 |
| `assets/photos/hero-05.jpg` | 上海瑞安新天地广场 / SHANGHAI SHUI ON XINTIANDI | `/uploads/tail_home/background_5/1/%E6%96%B0%E5%A4%A9%E5%9C%B01920x968.jpg` | https://www.thape.com/works/54 |
| `assets/photos/hero-06.jpg` | 苏州高新区文体中心 / SND CULTURAL & SPORTS CENTRE | `/uploads/tail_home/background_6/1/06_background.jpg` | https://www.thape.com/works/39 |
| `assets/photos/collection-01.jpg` | 重庆香港置地天湖岛 | `/uploads/tail_home/new_project_photo_1/1/%E5%A4%A9%E6%B9%96%E5%B2%9B_880x880.jpg` | https://www.thape.com/works/280 |
| `assets/photos/collection-02.jpg` | 剑桥大学南京科技创新中心 | `/uploads/tail_home/new_project_photo_3w/1/%E5%89%91%E6%A1%A5_1794x880.jpg` | https://www.thape.com/works/120 |
| `assets/photos/collection-03.jpg` | 长泰福隆·心乡谷 | `/uploads/tail_home/new_project_photo_5/1/%E5%BF%83%E4%B9%A1%E8%B0%B7_880x880.jpg` | https://www.thape.com/works/136 |

Hero photographs are the six desktop homepage images, not their mobile variants. The hero renderer assumes 1920 × 968 sources; collection cards assume 880 × 880, except the Cambridge image at 1794 × 880. English titles retain source wording; repeated spaces in the Wyndham title are normalized.

## Brand and rendering helpers

| Local path | Origin and purpose | Rights/scope |
| --- | --- | --- |
| `assets/brand/logo.svg` | Exact source repository file `app/packs/images/logo.svg`; the homepage embeds the same TIANHUA 天华 vector wordmark inline, so no standalone public image URL is claimed | Tianhua branding, all rights reserved |
| `assets/brand/logo.png` | Raster derivative of the source SVG, used on light backgrounds | Same Tianhua branding rights |
| `assets/brand/logo-white.png` | White raster derivative of the source SVG, used over photography | Same Tianhua branding rights |
| `assets/brand/hero-shade.png` | Locally generated gradient helper for text contrast over photographs; no website photo source | Project-generated rendering helper, not a licensed Tianhua photograph |
| `assets/brand/pixel.png` | Locally generated pixel helper for solid shapes and rules; no website source | Project-generated rendering helper |

Preserve the logo's original 1157:130 aspect ratio. Conversion to PNG or recoloring does not remove branding rights. Project code is covered by the MIT scope stated in the root `LICENSE.md`, including its required notice; that scope must not be presented as covering the whole media bundle. The two generated helper images are identified separately here rather than attributed to the website's photo catalog.

## Font

- `assets/fonts/TianhuaDisplaySans.otf` is a subset derived from the installed `NotoSansCJK-Regular.ttc`, Simplified Chinese face at collection index 2, and renamed **TianhuaDisplaySans**.
- `assets/fonts/LICENSE-Noto.txt` bundles the source package's notices, including the **SIL Open Font License 1.1** applicable to the font. Its Debian packaging notices are not a reason to relabel the font or project as GPL.
- Upstream source: https://github.com/notofonts/noto-cjk
- This font is a separate OFL-licensed dependency, not a Tianhua all-rights-reserved photograph or logo, and not MIT-licensed project code. Preserve its OFL notice and modified-family name when distributing an authorized copy of the project.
- The subset includes the presentation's selected characters, not the entire CJK repertoire. Rebuild it after any new copy introduces characters; include all labels, project titles, English text, digits and punctuation, then inspect native rendering for missing glyphs. Do not assume a font subset that works for current text will support new projects.

## Runtime and data boundary

DragonRuby 7.21 Pro is an externally installed, licensed runtime and is not an asset in this repository. No runtime redistribution or public repository push is included in this project. No private guest records, database exports, browser state or authentication data belong in the display or asset bundle.
