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
        <link rel="stylesheet" href="/css/layout.css" />
        <link rel="stylesheet" href="/css/404.css" />
        
        <!-- Scripts -->
        <script src="/js/web_components.js"></script>
    </head>
    <body>
        <div class="main-wrapper">
            {{ Header {} }}

            <div class="container">
                <style>
                    .header-404 {
                        border-bottom: 3px solid #000;
                        padding: 40px 20px;
                        text-align: center;
                        background: linear-gradient(135deg, #f8f8f8 0%, #e8e8e8 100%);
                        width: 100%;
                        max-width: 800px;
                        margin-bottom: 40px;
                        border-radius: 10px;
                        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
                    }

                    .error-section {
                        text-align: center;
                        width: 100%;
                        padding: 0 20px;
                    }

                    .error-code {
                        cursor: pointer;
                        font-size: 8em;
                        font-weight: bold;
                        color: #d32f2f;
                        margin-bottom: 20px;
                        text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
                    }

                    .error-title {
                        font-size: 2.5em;
                        font-weight: bold;
                        margin-bottom: 15px;
                        color: #000;
                    }

                    .error-subtitle {
                        font-size: 1.2em;
                        color: #666;
                        margin-bottom: 30px;
                        line-height: 1.5;
                    }

                    .error-message {
                        font-size: 1em;
                        color: #555;
                        margin-bottom: 30px;
                        line-height: 1.6;
                        font-style: italic;
                    }

                    .back-button {
                        background: #d32f2f;
                        color: white;
                        padding: 15px 30px;
                        border: none;
                        border-radius: 5px;
                        cursor: pointer;
                        text-decoration: none;
                        display: inline-block;
                        transition: background 0.3s ease;
                        font-family: "Georgia", "Times New Roman", serif;
                        font-size: 1.1em;
                        font-weight: bold;
                    }

                    .back-button:hover {
                        background: #b71c1c;
                        transform: translateY(-2px);
                        box-shadow: 0 4px 10px rgba(211, 47, 47, 0.3);
                    }

                    .fun-facts {
                        margin-top: 40px;
                        padding: 20px;
                        background: #f8f9fa;
                        border-radius: 8px;
                        border-left: 4px solid #d32f2f;
                    }

                    .fun-facts h3 {
                        color: #d32f2f;
                        margin-bottom: 10px;
                        font-size: 1.2em;
                    }

                    .fun-facts p {
                        color: #666;
                        font-size: 0.9em;
                        line-height: 1.5;
                    }

                    @media (max-width: 768px) {
                        .error-code {
                        font-size: 5em;
                        }

                        .error-title {
                        font-size: 1.8em;
                        }

                        .header-404 {
                        padding: 30px 15px;
                        margin-bottom: 30px;
                        }
                    }
                </style>

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