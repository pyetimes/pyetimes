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

            <div class="container"
                style="
                    max-width: 800px;
                    margin: 0 auto;
                    padding: 2rem;
                    font-size: 1.2rem;
                "
            >
                <h2>Sobre PyETimes</h2>
                <br/>
                <p>
                    PyETimes es un proyecto que nació como una broma dentro de nuestra comunidad de Discord, 
                    pero rápidamente se transformó en algo más. Aquí, buscamos capturar la esencia de nuestras 
                    interacciones diarias, los momentos memorables y las historias que nos unen.Lo que comenzó 
                    como una parodia dentro de nuestra comunidad —una broma entre mensajes y memes— fue tomando 
                    forma gracias al interés genuino de quienes participamos día a día. PyETimes ya no es solo 
                    un chiste interno: se ha convertido en un medio que busca registrar la historia de nuestro 
                    Discord, destacar momentos clave, y dar visibilidad a las voces que lo construyen. 
                    Es una forma de generar comunidad, conservar la memoria de lo vivido, y fortalecer el 
                    sentido de pertenencia entre quienes compartimos este espacio. Porque, al final, 
                    cada conversación deja huella, y PyETimes está para contarla.
                </p>
                <br/>
                <h3>¿Cómo puedo contribuir?</h3>
                <p>
                    Si quieres ser parte de PyETimes, puedes registrarte como autor y comenzar a escribir 
                    artículos sobre lo que sucede en nuestra comunidad. No necesitas ser un experto, solo 
                    tener ganas de compartir tus ideas y experiencias. Para eso comunicate con algún
                    administrador o moderador en el <a href="https://discord.gg/mcRqkA2zt6">Discord</a> y te ayudaremos a registrarte.
                </p>
                <br/>
                <h3>¿Cómo puedo contactar al equipo?</h3>
                <p>
                    Si tienes alguna pregunta, sugerencia o simplemente quieres charlar, puedes contactarnos 
                    a través de nuestro <a href="https://discord.gg/mcRqkA2zt6">Discord</a>. Estamos siempre abiertos a escuchar y mejorar PyETimes.
                </p>
                <br/>
                <h3>¿Cómo puedo apoyar el proyecto?</h3>
                <p>
                    Si te gusta PyETimes y quieres apoyarnos, puedes compartir nuestros artículos, 
                    participar en el <a href="https://discord.gg/mcRqkA2zt6">Discord</a>, o simplemente darnos tu feedback. 
                    Cada interacción cuenta y nos ayuda a crecer.
                </p>
                <br/>
                <h3>¿Sobre el código fuente y la licencia?</h3>
                <p>
                    El código fuente de PyETimes está disponible en nuestro repositorio de GitHub. 
                    Puedes contribuir al proyecto, reportar errores o sugerir mejoras a través de 
                    nuestro sistema de issues. La mayoría de los contenidos están bajo una licencia 
                    MIT que permite su uso y modificación, pero los artículos son propiedad de sus respectivos autores.
                </p>
                <p>
                    Puedes encontrar el código fuente en <a href="https://github.com/darilrt/pyetimes">GitHub</a>.
                </p>
                <p>
                    O el codigo del bot en <a href="github.com/C-Ewan/dsbot-pyetimes">GitHub</a>.
                </p>
            </div>
        </div>

        {{ Footer {} }}
    </body>
</html>