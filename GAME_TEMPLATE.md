# Multiplayer Party Game — Builder Template

This template gives you a complete, working multiplayer game shell. Online play, leaderboard, neumorphic design system, session persistence, consent, notifications — all pre-built. You only write the game.

Sections marked `[YOURS]` are where you build. Everything else is infrastructure — copy it, don't redesign it.

---

## How to use this template

Give this entire document to an AI in a new session and say:

> "Follow this template to build [your game name]. Here are the game rules: [your rules]. Fill in every [YOURS] section accordingly."

The AI will handle all the infrastructure and only need to think about your game mechanics.

---

## What the template handles for you

- Neumorphic soft-UI design system (shadows, cards, inputs, buttons)
- Per-player color themes that shift the whole UI on each turn
- Welcome screen, setup screen, lobby, entry phase, game screen, winner screen
- 2–6 player support, offline and online
- Online multiplayer via PeerJS WebRTC — room codes, star topology
- Turn-based target chain — players knock each other out in sequence
- Ranking/leaderboard — first out wins, last standing loses
- Session persistence — online guests get notified when it's their turn
- Cookie consent popup
- Floating background props, confetti, toasts, result overlays

---

## Part 1 — Identity `[YOURS]`

Fill these in first. They define the look and feel of your game.

```
GAME_NAME:     "[Your Game Name]"
TAGLINE:       "[One short line describing the game]"
HERO_EMOJI:    "[Single emoji that represents your game — shown large on welcome screen]"
```

### Props array `[YOURS]`
These emojis float upward in the background. Pick 10–14 that fit your game's theme.

```javascript
const PROPS = [
  // [YOURS] — pick emojis that match your game's vibe
  // example for a food game: '🍕','🍔','🌮','🍣','🍦','⭐','✨','🔥'
  // example for a word game: '📝','💬','🔤','❓','💡','⭐','✨','🎯'
];
```

### Color palette
The palette below is fixed infrastructure. Do not change it — it drives the per-player theming system.

```javascript
const COLORS = [
  { bg:'#55CC88', body:'#F2FFF9', ds:'rgba(60,155,100,0.28)',  ls:'rgba(255,255,255,0.90)' },
  { bg:'#85BBFF', body:'#F4F9FF', ds:'rgba(100,140,210,0.28)', ls:'rgba(255,255,255,0.90)' },
  { bg:'#FFD966', body:'#FFFDF2', ds:'rgba(195,170,80,0.28)',  ls:'rgba(255,255,255,0.90)' },
  { bg:'#66DDBB', body:'#F0FFFA', ds:'rgba(60,175,145,0.28)',  ls:'rgba(255,255,255,0.90)' },
  { bg:'#CC88FF', body:'#FAF4FF', ds:'rgba(155,100,210,0.28)', ls:'rgba(255,255,255,0.90)' },
  { bg:'#FFAA88', body:'#FFF8F4', ds:'rgba(195,130,90,0.28)',  ls:'rgba(255,255,255,0.90)' },
];
const DEFAULT_THEME = COLORS[0];
```

Primary action buttons are always `#FF85C2` (bright pink). This is intentional — it gives a consistent CTA color across all player turns.

---

## Part 2 — Design System (infrastructure, do not change)

### CSS variables
```css
:root {
  --body-bg:      #F2FFF9;
  --dark-sh:      rgba(60,155,100,0.28);
  --light-sh:     rgba(255,255,255,0.90);
  --text:         #1A4030;
  --muted:        #6A9E84;
  --accent:       #FF85C2;
  --radius:       22px;
  --font-fun:     'Fredoka One', cursive;
  --font-body:    'Nunito', sans-serif;

  --neu-raise:    8px 8px 18px var(--dark-sh), -8px -8px 18px var(--light-sh);
  --neu-sm:       5px 5px 10px var(--dark-sh), -5px -5px 10px var(--light-sh);
  --neu-xs:       3px 3px 7px  var(--dark-sh), -3px -3px 7px  var(--light-sh);
  --neu-inset:    inset 4px 4px 9px var(--dark-sh), inset -4px -4px 9px var(--light-sh);
  --neu-inset-sm: inset 3px 3px 6px var(--dark-sh), inset -3px -3px 6px var(--light-sh);
}
```

### Theme switching
Call this every time the active player changes. It shifts the entire UI to that player's palette.

```javascript
function applyTheme(playerOrColorObj) {
  const t = playerOrColorObj;
  document.documentElement.style.setProperty('--body-bg', t.body);
  document.documentElement.style.setProperty('--dark-sh',  t.ds);
  document.documentElement.style.setProperty('--light-sh', t.ls);
  document.body.style.background = t.body;
}
```

### Component classes (infrastructure)
| Class | Use |
|---|---|
| `.card` | Content container — raised neumorphic |
| `.btn` | Default neutral button — raised |
| `.btn-primary` | Main CTA — always pink |
| `.btn-blue` | Secondary action |
| `input[type=text/number/password]` | Inset (sunken) neumorphic |
| `.section-label` | Card heading with icon |
| `.back-btn` | Top-left navigation button |
| `.divider` | "or" separator between options |

---

## Part 3 — State (infrastructure + your fields)

```javascript
let G = makeState();

function makeState() {
  return {
    // ── INFRASTRUCTURE (do not change) ──────────────────────
    mode:           'offline',    // 'offline' | 'online-host' | 'online-guest'
    count:          2,
    players:        [],
    targets:        {},           // { playerId: targetPlayerId }
    queue:          [],           // active player IDs
    qIdx:           0,
    log:            {},           // { 'p0-p1': [ ...turn records ] }
    phase:          'setup',      // 'setup' | 'entering' | 'playing' | 'finished'
    rankCounter:    0,
    entryIdx:       0,
    peer:           null,
    connections:    [],
    conn:           null,
    myPlayerIndex:  -1,
    myId:           null,
    roomCode:       null,
    connectedSlots: new Set(),

    // ── [YOURS] — add your game's global state fields here ──
    // examples:
    //   roundNumber: 1,
    //   timeLimit: 30,
    //   category: null,
  };
}
```

### Player object (infrastructure + your fields)
```javascript
{
  id:          'p0',
  name:        'Alice',
  ...COLORS[i],          // bg, body, ds, ls spread in automatically
  rank:        null,     // null = playing, 1 = first winner, -1 = last place
  eliminated:  false,

  // ── [YOURS] — add per-player fields here ──
  // examples:
  //   secretValue: null,
  //   score: 0,
  //   lives: 3,
  //   chosenWord: null,
}
```

---

## Part 4 — Screen Flow (infrastructure)

Screens are `<div class="screen">` elements. Only one visible at a time.

```
welcome → [offline] → setup → entry → game → winner
        → [online]  → setup → lobby → entry → game → winner
                              ↑
                        (guests join here)
```

Infrastructure screens you get for free:
- `s-welcome` — hero emoji, game name, two mode buttons, notification bar
- `s-online` — create room / join with code
- `s-lobby` — room code display, connected players list, start button
- `s-winner` — trophy, ranked player list with revealed secrets

Screens you partially fill in:
- `s-setup` — player names always included; **add your game settings here**
- `s-entry` — pass-device secret entry; **you define what players enter**
- `s-game` — turn banner and player chips always included; **you build the action area**

---

## Part 5 — Setup Screen `[YOURS]`

The player name inputs and count stepper are already built. Below them, add a card for your game-specific settings.

```html
<!-- infrastructure: player count + names are here automatically -->

<!-- [YOURS] add a card below for game settings -->
<div class="card">
  <div class="section-label">⚙️ Game Settings</div>

  <!-- example: difficulty selector -->
  <div class="field">
    <label>Difficulty</label>
    <select id="difficulty">...</select>
  </div>

  <!-- example: round count -->
  <div class="field">
    <label>Rounds</label>
    <input type="number" id="rounds" value="3">
  </div>

  <!-- [YOURS] add whatever your game needs here -->
</div>
```

Read these values in `startSetup()` and store them in `G`.

---

## Part 6 — Entry Phase `[YOURS]`

This is the pass-the-device phase. Each player sets up their secret privately before the game starts.

**What's fixed:** the pass-device flow, progress dots, look-away UI, online handling.

**What you define:**

```javascript
// [YOURS] what does each player enter before the game?
// examples:
//   a secret number between 1 and 100
//   a secret word
//   a category choice
//   a drawing
//   a truth or dare choice
```

The entry screen has a `type="password"` input by default. For your game, change it to whatever input makes sense (text, select, drawing canvas, etc.).

On confirm, store the value:
```javascript
G.players[entryIdx].secretValue = /* whatever they entered */;
```

For online guests, the secret stays on their device. It is never sent over the network. The validation step (Part 8) is what keeps it private.

---

## Part 7 — Game Screen `[YOURS]`

### Fixed infrastructure (build this exactly)
```html
<!-- player chips — infrastructure, do not change -->
<div class="strip" id="strip"></div>

<!-- turn banner — infrastructure, do not change -->
<div class="turn-banner" id="turn-banner">
  <div class="t-name" id="t-who"></div>    <!-- "Alice's Turn" -->
  <div class="t-sub"  id="t-sub"></div>    <!-- [YOURS] what are they doing? -->
  <span class="range-pill" id="t-info"></span>  <!-- [YOURS] optional status pill -->
</div>
```

### History / status card `[YOURS]`
```html
<div class="card" style="flex:1">
  <div class="section-label">[YOURS] history icon + label</div>
  <div id="log-wrap">
    <!-- [YOURS] render turn history here -->
    <!-- each row: .log-row with emoji, value, hint -->
  </div>
</div>
```

### Action card `[YOURS]`
```html
<div class="card">
  <!-- [YOURS] the input + button for the current player's action -->
  <!-- examples:
    - text input + submit for word games
    - number input + submit for guessing games
    - multiple choice buttons for quiz games
    - timer display for speed games
  -->
</div>
```

### renderGame() function `[YOURS]`
This runs every time the turn changes. The infrastructure part is fixed; the rest is yours.

```javascript
function renderGame() {
  const cur = curP();     // current player
  const tgt = tgtOf(cur.id);  // their target

  // ── INFRASTRUCTURE (always run these) ────────────────
  applyTheme(cur);
  document.getElementById('turn-banner').style.background = cur.bg;
  document.getElementById('t-who').textContent = cur.name + "'s Turn";
  renderStrip();

  // ── [YOURS] ───────────────────────────────────────────
  document.getElementById('t-sub').textContent   = /* describe what cur is doing vs tgt */;
  document.getElementById('t-info').textContent  = /* optional: range, score, round info */;

  renderLog(cur.id, tgt.id);   // [YOURS] implement this to show turn history

  // online: disable action if it's not this player's turn
  if (G.mode !== 'offline') {
    const mine = cur.id === G.myId;
    /* [YOURS] enable/disable your action input based on `mine` */
  }
}
```

---

## Part 8 — Turn Logic `[YOURS]`

This is the core of your game. Write one function that handles a player's action.

```javascript
function submitAction() {
  const cur = curP();
  const tgt = tgtOf(cur.id);

  // [YOURS] read and validate the player's input
  const action = /* read from your input element */;
  if (/* invalid */) { toast('...'); return; }

  // clear input
  /* reset your input */

  // online routing (infrastructure — keep this pattern)
  if (G.mode === 'online-host') { processAction(cur.id, tgt.id, action); return; }
  if (G.mode === 'online-guest') {
    G.conn.send({ type: 'MAKE_ACTION', guesser: cur.id, target: tgt.id, action });
    return;
  }

  // offline: evaluate immediately
  const result = evaluateAction(action, tgt);
  showResultOverlay(result, action, cur, tgt);
}

function evaluateAction(action, targetPlayer) {
  // [YOURS] compare action against targetPlayer.secretValue
  // return a result object — e.g. { outcome: 'correct' } or { outcome: 'wrong', hint: 'try again' }
}
```

### After evaluation — call the right infrastructure function

```javascript
// If the action knocked out the target:
handleWin(guesser.id, target.id);   // ← infrastructure, do not modify

// If the action did not knock out the target:
advanceTurn();    // ← infrastructure
renderGame();     // ← infrastructure
```

`handleWin` manages elimination, target chain reassignment, rank assignment, and end-game detection. Never rewrite it.

---

## Part 9 — Result Overlay `[YOURS]`

The overlay infrastructure (positioning, fade in/out, animation) is fixed. You define what it shows.

```javascript
function showResultOverlay(result, action, cur, tgt) {
  const ov = document.getElementById('result-overlay');

  // reset animations
  roE.style.animation = 'none'; roT.style.animation = 'none';
  void roE.offsetWidth;
  roE.style.animation = ''; roT.style.animation = '';

  // [YOURS] set content based on result
  // example structure:
  if (result.outcome === 'correct') {
    ov.style.background = '#66DDBB';       // [YOURS] pick a color
    roE.textContent = '🎉';                // [YOURS] emoji
    roT.textContent = 'CORRECT!';          // [YOURS] headline
    roN.textContent = String(action);      // [YOURS] the value shown
    roS.textContent = cur.name + ' wins this round!';  // [YOURS] sub text
    ov.classList.add('show');
    launchConfetti();
    setTimeout(() => {
      ov.classList.remove('show');
      applyGuess(cur.id, tgt.id, action, result);
    }, 2800);
  } else {
    ov.style.background = /* [YOURS] color for this state */;
    roE.textContent = /* [YOURS] */;
    roT.textContent = /* [YOURS] headline */;
    roN.textContent = /* [YOURS] value */;
    roS.textContent = /* [YOURS] hint or feedback */;
    ov.classList.add('show');
    setTimeout(() => {
      ov.classList.remove('show');
      applyGuess(cur.id, tgt.id, action, result);
    }, 1800);   // shorter for non-win results
  }
}
```

---

## Part 10 — Gameplay Animations `[YOURS]`

The template has fixed animations for: confetti, toast slide, result overlay pop, background props drift, turn banner transition, player chip press.

For game-specific animations, add CSS keyframes and apply them in your `showResultOverlay` or `renderGame`:

```css
/* [YOURS] examples */
@keyframes shake {
  0%,100%{transform:translateX(0)} 25%{transform:translateX(-8px)} 75%{transform:translateX(8px)}
}
@keyframes bounce-in {
  0%{transform:scale(0)} 60%{transform:scale(1.15)} 100%{transform:scale(1)}
}
@keyframes pulse {
  0%,100%{opacity:1} 50%{opacity:0.4}
}
```

Apply by adding/removing a class on the element you want to animate.

---

## Part 11 — Online Multiplayer (infrastructure, do not change)

The messaging system uses 3-step action routing:

```
Guest submits action
  → sends MAKE_ACTION to host
    → host forwards VALIDATE to target guest (if target is a guest)
      → target validates locally (secret never leaves device)
        → sends VALIDATE_RESULT back to host
          → host applies result
            → host broadcasts STATE_SYNC to everyone
```

If the target is the host themselves, step 3–4 is skipped and the host validates directly.

### Message types (rename MAKE_ACTION / VALIDATE / VALIDATE_RESULT to match your game)

| Type | Direction | What you put in payload `[YOURS]` |
|---|---|---|
| `JOIN` | Guest → Host | nothing |
| `WELCOME` | Host → Guest | full G snapshot |
| `FULL` | Host → Guest | nothing |
| `START_ENTRY` | Host → All | players, targets, queue, range |
| `MAKE_ACTION` | Guest → Host | `guesser, target,` **[YOURS: your action data]** |
| `VALIDATE` | Host → Target | `guesser, target,` **[YOURS: your action data]** |
| `VALIDATE_RESULT` | Target → Host | `guesser, target,` **[YOURS: your action data + result]** |
| `STATE_SYNC` | Host → All | full G snapshot |

Only the payload contents of the three middle messages change per game.

---

## Part 12 — Log / History Rendering `[YOURS]`

Each turn's data is stored in `G.log['p0-p1']` as an array of records. You define what a record looks like.

```javascript
// store a record after each turn:
const key = gid + '-' + tid;
if (!G.log[key]) G.log[key] = [];
G.log[key].push({
  // [YOURS] whatever you want to remember about this turn
  // examples: { action: 'apple', result: 'wrong', hint: 'think bigger' }
  //           { guess: 42, result: 'higher' }
  //           { answer: 'Paris', correct: true }
});
```

```javascript
// render the log:
function renderLog(gid, tid) {
  const entries = G.log[gid + '-' + tid] || [];
  // [YOURS] map each entry to a .log-row div
  // each row has: an emoji, a main value, a hint/result label
}
```

---

## Part 13 — Winner Screen (infrastructure)

No changes needed here. The infrastructure reads `G.players`, sorts by `rank`, and renders:
- 1st place (rank 1) = winner, gets 🥇
- Last place (rank -1) = loser, gets 💔
- Middle players ranked in order

The only thing you customize is the **revealed secret** shown per player:

```javascript
// in the rankings render loop:
rank-secret.textContent = p.secretValue ?? '';   // [YOURS] show whatever they entered
```

---

## Part 14 — Initialization (infrastructure)

Always end your `<script>` with this exact sequence:

```javascript
applyTheme(DEFAULT_THEME);
startProps(10);
renderNameInputs();
checkConsent();
if (hasConsent()) checkPendingTurn();
```

---

## Summary — What you write vs what you get free

| Section | You write | Pre-built |
|---|---|---|
| Game name, emoji, tagline | ✅ | |
| PROPS array | ✅ | |
| Setup settings (beyond player names) | ✅ | |
| Secret entry input | ✅ | |
| Action input UI | ✅ | |
| `evaluateAction()` — game rules | ✅ | |
| `renderLog()` — history display | ✅ | |
| Result overlay content | ✅ | |
| Gameplay animations (CSS keyframes) | ✅ | |
| Online message payload fields | ✅ | |
| Revealed secret on winner screen | ✅ | |
| Design system, colors, neumorphism | | ✅ |
| All screen layouts and navigation | | ✅ |
| Turn order and player chip strip | | ✅ |
| Target chain + elimination logic | | ✅ |
| Ranking and leaderboard | | ✅ |
| Online multiplayer routing | | ✅ |
| Session persistence + notifications | | ✅ |
| Cookie consent | | ✅ |
| Confetti, toasts, result overlay shell | | ✅ |
| Background props animation | | ✅ |
