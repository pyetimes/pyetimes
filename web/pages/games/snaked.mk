{{
    use crate::web::components::{
        Meta,
        Header,
        Footer,
    };
}}
<!DOCTYPE html>
<html>
    <head>
        {{
            Meta {
                title: "Snaked - PyE Times",
                description: "Juega Snaked, nuestro juego de la serpiente.",
                ..Default::default()
            }
        }}

        <!-- Styles -->
        <link rel="stylesheet" href="/css/global.css" />
        <link rel="stylesheet" href="/css/layout.css" />
        <!-- Scripts -->
        <script src="/js/web_components.js"></script>


        <style>
            :root {
                --cell: 21px;
                --grid: #ccc;
                --bg: #ffffff;
            }

            .shell {
                width: min(calc(var(--cell) * 27), 92vw);
                display: grid;
                gap: 12px;
                margin: auto;
            }

            .hud {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 0px 12px;
            }

            .hud .stats {
                display: flex;
                gap: 16px;
                color: #000;
            }

            button {
                background: #111a21;
                color: #e8eef4;
                border: 1px solid #1c2833;
                border-radius: 10px;
                padding: 8px 12px;
                font-weight: 600;
                cursor: pointer;
            }

            .stage-wrap {
                position: relative;
                display: flex;
                gap: 0px;
            }

            canvas {
                width: 100%;
                height: auto;
                image-rendering: pixelated;
                background:
                    linear-gradient(var(--grid) 1px, transparent 1px) 0 0 /
                        var(--cell) var(--cell),
                    linear-gradient(90deg, var(--grid) 1px, transparent 1px) 0
                        0 / var(--cell) var(--cell),
                    #fff;
                border: 1px solid #151d24;
            }

            .overlay {
                position: absolute;
                inset: 0;
                display: grid;
                place-items: center;
                background: rgba(0, 0, 0, 0.28);
                color: #000;
                font-weight: 700;
                letter-spacing: 0.4px;
                text-align: center;
                user-select: none;
                cursor: pointer;
            }

            .overlay > div {
                background: #fff;
                border: 1px solid #16212a;
                padding: 14px 18px;
            }

            .muted {
                font-weight: 500;
                font-size: 12px;
                display: block;
                margin-top: 4px;
            }
        </style>
    </head>
    <body>
        <div class="main-wrapper">
            {{ Header {} }}

            <div class="container">
                <div class="shell">
                    <div class="hud">
                        <div>🐍 Snaked</div>
                        <div class="stats">
                            <span>Puntaje: <strong id="score">0</strong></span>
                            <span>Mejor: <strong id="best">0</strong></span>
                            <span>Vel.: <strong>0.5x</strong></span>
                        </div>
                        <div><button id="btn-restart">Reiniciar</button></div>
                    </div>
                    <div class="stage-wrap">
                        <canvas id="game" width="567" height="567"></canvas>
                        <div id="overlay" class="overlay">
                            <div>
                                Clic para empezar
                                <span class="muted">Usa flechas o WASD</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        {{ Footer {} }}

        <script>
            (() => {
                const IMAGES = {
                    head: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABUAAAAVCAYAAACpF6WWAAAAAXNSR0IArs4c6QAAAGxJREFUOI3dk9sOwCAIQ+3i//8ye3Je4kpn1MT1xUTtAUFC0GTNOk0y8JodeRkU4r3y6a5HgZpZZgJwfR60AqpgBu0CFfDWRtEsH/NLtjRTAMlI9z5BRxXZYa8ESln+MaZn/NOkoTE9p1FLoDcOGiIlQWzfRgAAAABJRU5ErkJggg==",
                    tail: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABUAAAAVCAYAAACpF6WWAAAAAXNSR0IArs4c6QAAAEpJREFUOI3t0jEKACAMQ9HE+985Lg5KrRXBweIbCxZ+kViTJDMkCQD0HpVg6ZErS92EznCCKB1P5e9Su4H9ChP58rGbjrT535dKBac5DwxjGgxfAAAAAElFTkSuQmCC",
                    body_straight:
                        "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABUAAAAVCAYAAACpF6WWAAAAAXNSR0IArs4c6QAAADBJREFUOI3tzMEJACAAw8DU/XeuA4gK4jN5FnrhXNsuYxKA7E7jgj4lKioqKir6oQn4owQq5kG40AAAAABJRU5ErkJggg==",
                    body_right:
                        "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABUAAAAVCAYAAACpF6WWAAAAAXNSR0IArs4c6QAAAGZJREFUOI3tksEOwCAIQ9tl///LeJgHCaLC4sXYmya8lioxloiIuSQJAPSGngk0pcOhtWdb9h/oTGlok9Ykdr+Fnnc3/SDUmDccse+qzls6XVkfKxVkoCFwBIr2pUcGUWjX4OpqswoVvSD/5ntjCgAAAABJRU5ErkJggg==",
                    tomate: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABUAAAAVCAYAAACpF6WWAAAAAXNSR0IArs4c6QAAAFpJREFUOI3tksEKwDAIQ+P+/5/TSwceltSN7dL5oAcpeQoKNNvA+XL9mVwSBdHt7OGEJEHyLPKHbai6MUtkOOLS4SZ9zM+l7qTsstSSVlIpdsKKFOIeK7nmRQYGsiD9TAuo1AAAAABJRU5ErkJggg==",
                    body_left:
                        "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABUAAAAVCAYAAACpF6WWAAAAAXNSR0IArs4c6QAAAGJJREFUOI3tkkEOwCAIBHcb///l7aGpBwuF4sGkcW5inCwC8Y4kPYokAYDeoyOQlviH1PzPWWmZZtSEK2ZZylvSjYEsWicAaDOJPNavVKb1T9KsEM70R1E/pgOM0zfuN5vVnIFkFCEN5psCAAAAAElFTkSuQmCC",
                };

                const CELL = 21,
                    COLS = 27,
                    ROWS = 27,
                    DIR = {
                        up: [0, -1],
                        right: [1, 0],
                        down: [0, 1],
                        left: [-1, 0],
                    },
                    OPP = {
                        up: "down",
                        right: "left",
                        down: "up",
                        left: "right",
                    };
                const OFF = {
                    head: Math.PI / 2,
                    tail: -Math.PI / 2,
                    straight: 0,
                    turn1: 0,
                    turn2: -Math.PI / 2,
                };
                const cvs = document.getElementById("game"),
                    ctx = cvs.getContext("2d"),
                    overlay = document.getElementById("overlay");
                const imgs = {},
                    speed = 96 * 2;
                let loaded = 0,
                    state = "ready",
                    snake = [],
                    dir = "right",
                    queue = [],
                    food = null,
                    score = 0,
                    best = +(localStorage.getItem("snake_best") || 0);
                document.getElementById("best").textContent = best;

                let canSpawnBeaver = true;
                let tomatoesSinceBeaver = 0;
                let foodTimer = null;
                let foodTime = 0;
                let blink = false;

                const loadAll = () => {
                    for (const [k, src] of Object.entries(IMAGES)) {
                        const im = new Image();
                        im.onload = im.onerror = () => {
                            if (++loaded === Object.keys(IMAGES).length) init();
                        };
                        im.src = src;
                        imgs[k] = im;
                    }
                };
                const randCell = () => ({
                    x: (Math.random() * COLS) | 0,
                    y: (Math.random() * ROWS) | 0,
                });
                const collides = (x, y) =>
                    snake.some((s) => s.x === x && s.y === y);
                const eulerAngle = (dx, dy) => Math.atan2(dy, dx);
                const drawRot = (img, x, y, θ, flip = false) => {
                    const c = Math.cos(θ),
                        s = Math.sin(θ);
                    ctx.save();
                    ctx.translate(x * CELL + CELL / 2, y * CELL + CELL / 2);
                    ctx.transform(flip ? -c : c, s, -s, flip ? c : c, 0, 0);
                    ctx.drawImage(img, -CELL / 2, -CELL / 2, CELL, CELL);
                    ctx.restore();
                };
                const complexStep = (x, y, dx, dy) => ({
                    x: (x + dx + COLS) % COLS,
                    y: (y + dy + ROWS) % ROWS,
                });
                const updateScore = () => {
                    document.getElementById("score").textContent = score;
                    document.getElementById("best").textContent = best;
                };

                let timer = null;
                const startLoop = () => {
                    clearInterval(timer);
                    timer = setInterval(step, speed);
                };
                const stopLoop = () => clearInterval(timer);

                function init() {
                    newGame();
                    render();
                }

                function newGame() {
                    const cx = (COLS / 2) | 0,
                        cy = (ROWS / 2) | 0;
                    dir = "right";
                    queue = [];
                    score = 0;
                    updateScore();
                    snake = [];
                    for (let i = 3; i >= 0; i--)
                        snake.push({ x: cx - i, y: cy });
                    placeFoodStable();
                    state = "ready";
                    stopLoop();
                    overlay.style.display = "grid";
                }

                function resetFoodTimer() {
                    clearInterval(foodTimer);
                    foodTime = 0;
                    blink = false;
                    foodTimer = setInterval(() => {
                        foodTime += 1;
                        if (foodTime >= 7) {
                            blink = !blink;
                            if (foodTime % 2 === 0) {
                                placeFoodRandom();
                                resetFoodTimer();
                            }
                        }
                    }, 1000);
                }

                function placeFoodStable() {
                    let x = (COLS * 0.75) | 0,
                        y = (ROWS * 0.25) | 0;
                    if (collides(x, y)) {
                        let t = 0;
                        do {
                            x = (x + 3) % COLS;
                            y = (y + 5) % ROWS;
                            t++;
                        } while (collides(x, y) && t < 100);
                    }
                    food = { x, y, type: chooseFoodType() };
                    resetFoodTimer();
                }

                function placeFoodRandom() {
                    let p,
                        t = 0;
                    do {
                        p = randCell();
                        t++;
                    } while (collides(p.x, p.y) && t < 200);
                    food = { x: p.x, y: p.y, type: chooseFoodType() };
                    resetFoodTimer();
                }

                function chooseFoodType() {
                    const maxTomatoes =
                        tomatoesSinceBeaver >=
                        Math.floor(Math.random() * 6) + 2;
                    if (maxTomatoes) {
                        tomatoesSinceBeaver = 0;
                        canSpawnBeaver = false;
                        return "beaver";
                    }

                    tomatoesSinceBeaver++;
                    return "tomate";
                }

                function step() {
                    if (state !== "running") return;
                    if (queue.length) {
                        const nd = queue.shift();
                        if (OPP[nd] !== dir) dir = nd;
                    }
                    const h = snake[0],
                        d = DIR[dir],
                        { x: nx, y: ny } = complexStep(h.x, h.y, d[0], d[1]);
                    if (collides(nx, ny)) return newGame();
                    const ate = food && food.x === nx && food.y === ny;
                    snake.unshift({ x: nx, y: ny });
                    if (ate) {
                        clearInterval(foodTimer);
                        score++;
                        if (score > best) {
                            best = score;
                            localStorage.setItem("snake_best", best);
                        }
                        updateScore();
                        if (food.type === "beaver") canSpawnBeaver = true;
                        placeFoodRandom();
                    } else snake.pop();
                    render();
                }

                function render() {
                    ctx.clearRect(0, 0, cvs.width, cvs.height);
                    if (food) {
                        if (food.type === "tomate") {
                            if (blink && foodTime >= 7) {
                                ctx.save();
                                ctx.filter =
                                    "brightness(1.8) saturate(2) hue-rotate(-20deg)";
                                ctx.globalAlpha =
                                    Math.sin(Date.now() / 120) * 0.4 + 0.6;
                                ctx.drawImage(
                                    imgs.tomate,
                                    food.x * CELL,
                                    food.y * CELL,
                                    CELL,
                                    CELL,
                                );
                                ctx.restore();
                            } else {
                                ctx.drawImage(
                                    imgs.tomate,
                                    food.x * CELL,
                                    food.y * CELL,
                                    CELL,
                                    CELL,
                                );
                            }
                        } else {
                            ctx.save();
                            ctx.translate(
                                food.x * CELL + CELL / 2,
                                food.y * CELL + CELL * 0.72,
                            );
                            ctx.font =
                                CELL +
                                "px system-ui, Apple Color Emoji, Segoe UI Emoji";
                            ctx.textAlign = "center";
                            ctx.textBaseline = "middle";
                            ctx.fillText("🦫", 0, 0);
                            ctx.restore();
                        }
                    }
                    for (let i = 0; i < snake.length; i++) {
                        const seg = snake[i];
                        if (i === 0) {
                            const next = snake[1],
                                ang =
                                    eulerAngle(
                                        -(next.x - seg.x),
                                        -(next.y - seg.y),
                                    ) + OFF.head;
                            drawRot(imgs.head, seg.x, seg.y, ang);
                        } else if (i === snake.length - 1) {
                            const prev = snake[i - 1],
                                ang =
                                    eulerAngle(seg.x - prev.x, seg.y - prev.y) +
                                    OFF.tail;
                            drawRot(imgs.tail, seg.x, seg.y, ang);
                        } else {
                            const p = snake[i - 1],
                                n = snake[i + 1];
                            const dx1 = seg.x - p.x,
                                dy1 = seg.y - p.y;
                            const dx2 = n.x - seg.x,
                                dy2 = n.y - seg.y;
                            const straight = dx1 === dx2 || dy1 === dy2;

                            if (straight) {
                                const ang =
                                    (dx1 === 0 ? 0 : Math.PI / 2) +
                                    OFF.straight;
                                drawRot(imgs.body_straight, seg.x, seg.y, ang);
                            } else {
                                let ang = 0;
                                const cross = dx1 * dy2 - dy1 * dx2;
                                const leftTurn = cross > 0;

                                if (
                                    (dx1 === 1 &&
                                        dy1 === 0 &&
                                        dx2 === 0 &&
                                        dy2 === 1) ||
                                    (dx2 === 1 &&
                                        dy2 === 0 &&
                                        dx1 === 0 &&
                                        dy1 === 1)
                                )
                                    ang = 0;
                                else if (
                                    (dx1 === 0 &&
                                        dy1 === 1 &&
                                        dx2 === -1 &&
                                        dy2 === 0) ||
                                    (dx2 === 0 &&
                                        dy2 === 1 &&
                                        dx1 === -1 &&
                                        dy1 === 0)
                                )
                                    ang = Math.PI / 2;
                                else if (
                                    (dx1 === -1 &&
                                        dy1 === 0 &&
                                        dx2 === 0 &&
                                        dy2 === -1) ||
                                    (dx2 === -1 &&
                                        dy2 === 0 &&
                                        dx1 === 0 &&
                                        dy1 === -1)
                                )
                                    ang = Math.PI;
                                else if (
                                    (dx1 === 0 &&
                                        dy1 === -1 &&
                                        dx2 === 1 &&
                                        dy2 === 0) ||
                                    (dx2 === 0 &&
                                        dy2 === -1 &&
                                        dx1 === 1 &&
                                        dy1 === 0)
                                )
                                    ang = -Math.PI / 2;

                                const img = leftTurn
                                    ? imgs.body_left
                                    : imgs.body_right;
                                drawRot(
                                    img,
                                    seg.x,
                                    seg.y,
                                    ang + (leftTurn ? OFF.turn2 : OFF.turn1),
                                );
                            }
                        }
                    }
                }

                const KEY2DIR = {
                    ArrowUp: "up",
                    KeyW: "up",
                    ArrowRight: "right",
                    KeyD: "right",
                    ArrowDown: "down",
                    KeyS: "down",
                    ArrowLeft: "left",
                    KeyA: "left",
                };

                const begin = () => {
                    if (state === "running") return;
                    state = "running";
                    overlay.style.display = "none";
                    startLoop();
                };

                addEventListener("keydown", (e) => {
                    const nd = KEY2DIR[e.code];
                    if (!nd) return;
                    begin();
                    e.preventDefault();
                    const last = queue.length ? queue[queue.length - 1] : dir;
                    if (OPP[nd] === last) return;
                    queue.push(nd);
                });
                document.getElementById("btn-restart").onclick = () => {
                    newGame();
                    render();
                };
                loadAll();
            })();
        </script>
    </body>
</html>
