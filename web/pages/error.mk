{{
    use crate::web::components::{ 
        Meta,
        Header,
        Footer,
    };
    use crate::error::ProblemDetails;

    let ProblemDetails { title, status, detail } = &props.details;
}}
<!DOCTYPE html>
<html>
    <head>
        {{ 
            Meta {
                title: format!("Error {} - PyE Times", 500).as_str(),
                description: "Lo sentimos, a ocurrió un error inesperado.",
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
                    <div class="error-code">{{ *status }}</div>
                    <h1 class="error-title">Error {{ *status }}</h1>
                    <p class="error-subtitle">¡Ups! A ocurrido un error inesperado.</p>

                    <p class="error-message"></p>

                    <a href="/" class="back-button">← Volver al PyE Times</a>

                    <div class="fun-facts">
                        <h3>💡 Dato Curioso</h3>
                        <p>
                            El famoso error HTTP 418 "I'm a teapot" no es un error real que verás en la práctica, 
                            ¡es una broma! Este código de estado fue definido en 1998 como parte de un protocolo 
                            de broma llamado "Hyper Text Coffee Pot Control Protocol" (HTCPCP). Su significado 
                            literal es: "Soy una tetera", y se usa para indicar que el servidor no puede preparar 
                            café porque es una tetera.
                        </p>
                    </div>
                </div>

                <script>
                    const errorMessages = [
                        "A ocurrido un error inesperado. Nuestros desarrolladores están investigando si esto es un bug o un feature no documentado.",
                        "Si ha causado algun problema es culpa de Phosphorus, no de nosotros.",
                        "¡Ups! Parece que algo malio sal. Nuestros desarrolladores están trabajando para solucionarlo.",
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