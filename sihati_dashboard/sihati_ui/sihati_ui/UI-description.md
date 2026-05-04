1️⃣ DESIGN SYSTEM FOUNDATION
Prompt for Colors:
Create a comprehensive color system based on primary blue (#2E7BF6) with the following:

PRIMARY COLORS:

- Primary: #2E7BF6 (Medical Blue)
- Primary Dark: #1E5BC6
- Primary Light: #5B9BFF
- Primary Soft: #E8F2FF

SECONDARY & ACCENT:

- Secondary: #00BFA5 (Teal)
- Secondary Light: #4DD0B8
- Secondary Dark: #00897B
- Accent: #FF6B35 (Orange)

SEMANTIC COLORS:

- Success: #10B981 (Green)
- Success Light: #D1FAE5
- Success Dark: #047857
- Warning: #F59E0B (Amber)
- Warning Light: #FEF3C7
- Warning Dark: #D97706
- Error: #EF4444 (Red)
- Error Light: #FEE2E2
- Error Dark: #DC2626
- Info: #3B82F6 (Blue)
- Info Light: #DBEAFE
- Info Dark: #1E40AF

NEUTRALS:

- Background: #F9FAFB
- Surface: #FFFFFF
- Border: #E5E7EB
- Text Primary: #111827
- Text Secondary: #6B7280
- Text Tertiary: #9CA3AF

GRADIENTS:

- Primary Gradient: linear-gradient(135deg, #2E7BF6 0%, #1E5BC6 100%)
- AI Gradient: linear-gradient(135deg, #667EEA 0%, #764BA2 100%)
- Health Gradient: linear-gradient(135deg, #10B981 0%, #059669 100%)
- Emergency Gradient: linear-gradient(135deg, #EF4444 0%, #DC2626 100%)
- Location Gradient: linear-gradient(135deg, #F59E0B 0%, #D97706 100%)

SHADOWS:

- Small: 0 2px 8px rgba(0, 0, 0, 0.04)
- Medium: 0 4px 12px rgba(0, 0, 0, 0.08)
- Large: 0 8px 24px rgba(0, 0, 0, 0.12)
- XL: 0 12px 40px rgba(0, 0, 0, 0.16)
- Primary Shadow: 0 8px 24px rgba(46, 123, 246, 0.24)

COLOR USAGE RULES (80/15/5):

- 80% Primary Blue for headers, icons, buttons, main actions
- 15% Semantic colors (red for location, teal for phone, etc.)
- 5% White/neutrals for backgrounds

Prompt for Typography:
Create a typography system using Poppins font with these specifications:

FONT FAMILY:

- Primary: 'Poppins', sans-serif
- Weights: 400 (Regular), 500 (Medium), 600 (Semi-Bold), 700 (Bold)

DISPLAY STYLES:

- Display Large: 32px / 700 bold / line-height: 1.2
- Display Medium: 28px / 700 bold / line-height: 1.2
- Display Small: 24px / 700 bold / line-height: 1.2

HEADING STYLES:

- H1: 32px / 700 bold / line-height: 1.25
- H2: 28px / 700 bold / line-height: 1.3
- H3: 24px / 700 bold / line-height: 1.3
- H4: 20px / 600 semi-bold / line-height: 1.4
- H5: 18px / 600 semi-bold / line-height: 1.4
- H6: 16px / 600 semi-bold / line-height: 1.4

BODY STYLES:

- Body Large: 16px / 400 regular / line-height: 1.5
- Body Medium: 14px / 400 regular / line-height: 1.5
- Body Small: 12px / 400 regular / line-height: 1.5

LABEL & CAPTION:

- Label: 14px / 500 medium / line-height: 1.4
- Caption: 12px / 400 regular / line-height: 1.4
- Button: 14px / 600 semi-bold / line-height: 1.4

SPECIAL STYLES:

- Large titles: letter-spacing: -0.5px
- Headers in wave sections: color: #FFFFFF
- Pill badges: 13px / 600 semi-bold

Prompt for Spacing:
Create a consistent spacing system based on 4px base unit:

SPACING SCALE:

- xs: 4px (0.25rem)
- sm: 8px (0.5rem)
- md: 16px (1rem)
- lg: 24px (1.5rem)
- xl: 32px (2rem)
- xxl: 48px (3rem)
- xxxl: 64px (4rem)

BORDER RADIUS:

- xs: 4px
- sm: 8px
- md: 12px
- lg: 16px
- xl: 20px
- xxl: 24px
- full: 999px (pills)

CONTAINER SPACING:

- Screen padding: 16px (md)
- Card padding: 16px (md)
- Section spacing: 24px (lg)
- Element margin: 12px (between items)

TOUCH TARGETS:

- Minimum: 44px
- Button height: 56px
- Icon button: 48px

2️⃣ WAVE HEADER PATTERN
Prompt for Wave Header Component:
Create a reusable wave header component with these specifications:

DIMENSIONS:

- Height: 200px (expandable)
- Wave curve height: 40px at bottom

VISUAL ELEMENTS:

1. Background: Primary gradient (135deg, #2E7BF6 to #1E5BC6)

2. Wave SVG Path (at bottom):
   - Start at 50% height on left
   - Curve down to 20% via quadratic bezier at 25% width
   - Curve back to 50% via quadratic bezier at 50% width
   - Curve down to 80% via quadratic bezier at 75% width
   - Curve back to 50% at right edge
   - Fill with background color (#F9FAFB)

3. Decorative Circles (white, low opacity):
   - Large circle: 120px diameter, opacity 0.1, top-right
   - Medium circle: 80px diameter, opacity 0.08, top-left
   - Small circle: 60px diameter, opacity 0.12, middle-right

4. Content Layout:
   - Icon container: white 25% opacity, 14px padding, 16px border-radius
   - Icon size: 32px, white color
   - Title: 28px bold, white, letter-spacing -0.5px
   - Subtitle badge: white 25% opacity background, 12px horizontal padding, 5px vertical, 20px border-radius
   - Badge text: 13px semi-bold, white

POSITIONING:

- Content aligned to bottom with 36px bottom padding
- Safe area aware for mobile notches
- Responsive to screen width

3️⃣ CARD COMPONENTS STYLING
Prompt for Standard Card:
Create a standard card component with:

CONTAINER:

- Background: #FFFFFF
- Border: 1px solid #E5E7EB
- Border radius: 16px
- Shadow: 0 2px 8px rgba(0, 0, 0, 0.04)
- Padding: 16px

HOVER STATE:

- Shadow: 0 4px 12px rgba(0, 0, 0, 0.08)
- Transform: translateY(-2px)
- Transition: all 0.2s ease

ICON CONTAINER:

- Background: #E8F2FF (primarySoft)
- Padding: 12px
- Border radius: 12px
- Icon color: #2E7BF6 (primary)
- Icon size: 26-28px

Prompt for "De Garde" Special Card:
Create a special highlighted card for duty pharmacies:

CONTAINER:

- Background: #FFFFFF
- Border: 2px solid rgba(46, 123, 246, 0.3)
- Border radius: 18px
- Shadow: 0 8px 24px rgba(46, 123, 246, 0.15) (blue glow)
- Padding: 20px

ICON CONTAINER:

- Background: Primary gradient
- Icon color: #FFFFFF
- Padding: 12px
- Border radius: 14px

BADGE:

- Background: Primary gradient
- Text: "DE GARDE" white, 11px bold
- Padding: 8px horizontal, 4px vertical
- Border radius: 20px (pill)
- Icon: Moon icon, 10px, white
- Position: Below pharmacy name

DIVIDER:

- Height: 1px
- Background: Linear gradient (primary 10% → 30% → 10%)
- Margin: 16px vertical

4️⃣ SEARCH BAR STYLING
Prompt for Search Bar:
Create a modern search input with:

CONTAINER:

- Background: #FFFFFF
- Border: 1.5px solid #E5E7EB
- Border radius: 18px
- Shadow: 0 6px 16px rgba(46, 123, 246, 0.1)
- Height: 56px

INPUT:

- Padding: 16px horizontal
- Font: 15px regular
- Placeholder color: #9CA3AF

ICONS:

- Search icon: 24px, #2E7BF6, left side, 12px padding
- Optional mic icon: 24px, #2E7BF6, right side

FOCUS STATE:

- Border color: #2E7BF6
- Shadow: 0 6px 20px rgba(46, 123, 246, 0.2)

5️⃣ BUTTON STYLING
Prompt for Primary Button:
Create a primary action button:

CONTAINER:

- Background: Primary gradient (135deg, #2E7BF6 to #1E5BC6)
- Height: 56px
- Border radius: 16px
- Shadow: 0 8px 16px rgba(46, 123, 246, 0.4)
- Padding: 16px horizontal

TEXT:

- Color: #FFFFFF
- Font: 16px bold
- Center aligned

STATES:

- Hover: Shadow 0 12px 24px rgba(46, 123, 246, 0.5)
- Active: Transform scale(0.98)
- Disabled: Opacity 0.5
- Loading: Show spinner, 24px white

ICON BUTTON (Square):

- Size: 58x58px
- Same gradient background
- Icon: 26px white
- Border radius: 18px

6️⃣ FILTER CHIPS STYLING
Prompt for Filter Chips:
Create interactive filter chips:

SELECTED STATE:

- Background: #E8F2FF (primarySoft)
- Border: 1px solid rgba(46, 123, 246, 0.3)
- Text color: #2E7BF6
- Font: 13px semi-bold
- Padding: 12px horizontal, 10px vertical
- Border radius: 20px

CLOSE BUTTON:

- Background: #2E7BF6 circle
- Icon: white X, 12px
- Size: 16px circle
- Position: right side with 8px gap

CLEAR ALL CHIP (Red):

- Background: #FEE2E2 (errorLight)
- Border: 1px solid rgba(239, 68, 68, 0.3)
- Text color: #EF4444
- Icon: X, 16px, red

7️⃣ EMPTY STATE STYLING
Prompt for Empty State:
Create an empty state component:

ICON CONTAINER:

- Background: #E8F2FF (primarySoft)
- Shape: Circle
- Padding: 32px
- Icon: 64px, primary color with 50% opacity

TEXT:

- Title: 18px bold, #111827
- Subtitle: 14px regular, #6B7280, line-height 1.5
- Spacing: 12px between title and subtitle

ACTION BUTTON:

- Primary gradient background
- 56px height
- 32px horizontal padding
- 16px vertical padding
- Text: 16px bold white

8️⃣ SUCCESS BANNER STYLING
Prompt for Success Banner:
Create a success notification banner:

CONTAINER:

- Background: Linear gradient (#D1FAE5 to rgba(209, 250, 229, 0.5))
- Border: 1.5px solid rgba(16, 185, 129, 0.3)
- Border radius: 18px
- Padding: 20px

ICON CONTAINER:

- Background: #10B981 (success)
- Border radius: 12px
- Padding: 12px
- Icon: checkmark, white, 22px
- Shadow: 0 2px 8px rgba(16, 185, 129, 0.3)

TEXT:

- Title: 16px bold, #047857 (success dark)
- Subtitle: 13px medium, rgba(4, 120, 87, 0.8)
- Spacing: 16px left of icon

9️⃣ LOCATION TOGGLE STYLING
Prompt for Location Toggle:
Create a location filter toggle:

CONTAINER:

- Background: Linear gradient (#E8F2FF to rgba(232, 242, 255, 0.5))
- Border: 1.5px solid rgba(46, 123, 246, 0.25)
- Border radius: 16px
- Padding: 18px

ICON CONTAINER (Active):

- Background: #2E7BF6
- Icon: location pin, white, 20px
- Padding: 10px
- Border radius: 12px
- Shadow: 0 2px 8px rgba(46, 123, 246, 0.3)

ICON CONTAINER (Inactive):

- Background: #FFFFFF
- Icon: location pin, #2E7BF6, 20px
- Padding: 10px
- Border radius: 12px

TEXT:

- Font: 15px bold
- Color: #2E7BF6

SWITCH:

- Active color: #2E7BF6
- Track height: 24px
  You want to add the DNA logo + Lottie animation section to your design system document. Here it is, ready to paste:

🔟 LOGO & ANIMATION SYSTEM
DNA Logo Mark:
The Sihati logo is a DNA double helix where two strands cross forming an S shape. Built from these exact elements:
STRANDS:

Strand A (white): cubic bezier path from (196,52) → (150,150) → (104,248), control points through (240,80) and (60,180), stroke-width 22px, round linecaps
Strand B (teal #00BFA5): mirror path from (104,52) → (150,150) → (196,248), control points through (60,80) and (240,180), stroke-width 22px, round linecaps

BACKBONE RUNGS (6 horizontal bars connecting the strands):

y=80: x=119 to x=181, opacity 55%, width 7px
y=108: x=132 to x=168, opacity 45%, width 7px
y=130: x=142 to x=158, opacity 32%, width 7px
y=170: x=142 to x=158, opacity 32%, width 7px
y=192: x=132 to x=168, opacity 45%, width 7px
y=220: x=119 to x=181, opacity 55%, width 7px
Color: white, round linecaps
Rung endpoint dots: 5px radius, alternating #00BFA5 and white

CENTER DOT (S waist pivot — 3 layered circles):

Outer: r=18, background color (erases strands at crossing)
Middle: r=12, color #64FFDA (bright mint)
Inner: r=6, white, pulses infinitely

TERMINAL DOTS (4 strand endpoints):

Top-right (196,52): r=13, white
Top-left (104,52): r=13, #00BFA5
Bottom-left (104,248): r=13, white
Bottom-right (196,248): r=13, #00BFA5

CANVAS: 300×300px viewBox, transparent background

LOGO VARIANTS:
FileBackgroundUse casesihati_icon_primary.svg#2E7BF6 blue, rx=72App icon, home headersihati_icon_dark.svg#07142a dark navy, rx=72Dark screenssihati_icon_white.svgWhite + border, rx=72Light backgroundssihati_icon_transparent.svgNoneWave headers, splash, lockupsihati_lockup.svgNoneFull brand mark with SIHATI textsihati_wordmark_white.svgNoneWhite text onlysihati_wordmark_dark.svgNoneDark blue text only

LOTTIE ANIMATION (sihati_dna.json):
FORMAT: Lottie JSON v5.9.0, 60fps, 120 frames (2 seconds), 300×300px, transparent background
ANIMATION SEQUENCE:

0→54f (0→0.9s): Strand A (white) draws in top to bottom via trim path, cubic-bezier(0.4,0,0.2,1)
15→63f (0.25→1.05s): Strand B (teal) draws in simultaneously with slight delay
36→72f (0.6→1.2s): 6 backbone rung lines scale-in from center outward, staggered outside→inside, each fades and scales from scaleX=0
36→72f: 12 rung endpoint dots pop in with spring bounce (cubic-bezier 0.34,1.56,0.64,1) alongside their rungs
0→18f: Top terminal dots pop in immediately as strands start
66→84f: Bottom terminal dots pop in as strands finish
72→96f: Center dot layers pop in — bg disc → teal disc → white dot, all spring bounce
84→120f: White center dot pulses infinitely (opacity 100%→35%→100%, 1.8s loop)

USAGE IN FLUTTER:
dartLottie.asset(
'assets/animations/sihati_dna.json',
width: 140, // splash screen
width: 80, // login/register header
width: 56, // profile header
repeat: false, // plays once — set true for loading states
)
USAGE IN HTML/CSS/JS:
javascriptlottie.loadAnimation({
container: document.getElementById('sihati-logo'),
renderer: 'svg',
loop: false,
autoplay: true,
path: 'assets/sihati_dna.json'
// or animationData: jsonObject for inline
});
WORDMARK ANIMATION (coordinated with Lottie via Flutter AnimationController):

Wordmark slides up + fades in at 59% of 2.2s controller (after DNA finishes)
Tagline follows at 68%
Bottom elements (spinner, version) fade in at 80%
Easing: Curves.easeOut on all text reveals
