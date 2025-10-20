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
                title: "Juegos - PyE Times",
                description: "Disfruta de nuestros juegos desarrollados internamente.",
                ..Default::default()
            }
        }}

        <!-- Styles -->
        <link rel="stylesheet" href="/css/global.css" />
        <link rel="stylesheet" href="/css/layout.css" />
        <link rel="stylesheet" href="/css/games.css" />

        <!-- Scripts -->
        <script src="/js/web_components.js"></script>
    </head>
    <body>
        <div class="main-wrapper">
            {{ Header {} }}

            <div class="container">
                <a class="game" href="/games/crossword">
                    <img src="/images/crossword_thumbnail.png" alt="Snaked Game"/>
                    <span>Crucigrama</span>
                </a>
                <a class="game" href="/games/sudoku">
                    <img src="/images/sudoku_thumbnail.png" alt="Snaked Game"/>
                    <span>Sudoku</span>
                </a>
                <a class="game" href="/games/snaked">
                    <img src="/images/snaked_thumbnail.png" alt="Snaked Game"/>
                    <span>Snaked</span>
                </a>
            </div>
        </div>

        {{ Footer {} }}
    </body>
</html>
