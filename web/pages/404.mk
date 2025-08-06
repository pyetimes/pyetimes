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
                title: "Página No Encontrada - PyE Times",
                description: "Lo sentimos, la página que buscas no existe.",
                ..Default::default()
            }
        }}
        
        <!-- Styles -->
        <link rel="stylesheet" href="/css/global.css" />
        <link rel="stylesheet" href="/css/layout.css" />
        <link rel="stylesheet" href="/css/404.css" />
        
        <!-- Scripts -->
        <script src="/js/web_components.js"></script>
    </head>
    <body>
        <div class="main-wrapper">
            {{ Header {} }}

            <div class="container">
                <div class="error-section">
                    <div class="error-code">404</div>
                    <h1 class="error-title">Página No Encontrada</h1>
                    <p class="error-subtitle">¡Ups! Esta página se perdió en el merge conflict</p>

                    <p class="error-message">
                        "La página que buscas no existe o fue víctima de un rollback inesperado.
                        Nuestros desarrolladores están investigando si esto es un bug o un feature
                        no documentado."
                    </p>

                    <a href="/" class="back-button">← Volver al PyE Times</a>

                    <div class="fun-facts">
                        <h3>💡 Dato Curioso</h3>
                        <p>
                        El error 404 fue nombrado así por la oficina 404 en el CERN donde se
                        encontraba el primer servidor web. En PyE TIMES, nuestros errores 404 son
                        causados principalmente por developers que olvidan hacer push de sus
                        commits.
                        </p>
                    </div>
                </div>

                <script>
                    const errorMessages = [
                        "Esta página está tomando un break como los developers en sprint review.",
                        "Error 404: Página no encontrada. ¿Probaste con Ctrl+F5?",
                        "La página que buscas está en otra branch del repositorio.",
                        "Esta URL fue deprecada en la versión 2.0 de la realidad.",
                        "Página no encontrada. Probablemente la borró alguien sin hacer backup.",
                        "404: Página perdida en el merge conflict del tiempo.",
                        "Esta página se fue de vacaciones sin avisar.",
                        "Error 404: Página no encontrada. ¿Has probado reiniciar tu navegador?",
                        "La página que buscas fue eliminada por un commit accidental.",
                        "404: Página no encontrada. Quizás está en el limbo de los commits perdidos.",
                    ];

                    // Function to change the error message randomly
                    function changeErrorMessage() {
                        const randomMessage =
                        errorMessages[Math.floor(Math.random() * errorMessages.length)];
                        document.querySelector(".error-message").textContent = `"${randomMessage}"`;
                    }

                    // Add click event listener to the error code
                    document.querySelector(".error-code").addEventListener("click", function () {
                        changeErrorMessage();
                    });

                    // On page load, change the error message
                    document.addEventListener("DOMContentLoaded", function () {
                        changeErrorMessage();
                    });
                </script>
            </div>
        </div>

        {{ Footer {} }}
    </body>
</html>