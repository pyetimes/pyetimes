
class Time extends HTMLElement {
    constructor() {
        super();
    }

    connectedCallback() {
        const timestamp = this.getAttribute("timestamp");
        if (timestamp) {
            const date = new Date(parseInt(timestamp, 10) * 1000);
            this.textContent = date.toLocaleDateString("es-ES", {
                weekday: "long",
                year: "numeric",
                month: "long",
                day: "numeric",
            });
        } else {
            this.textContent = "Fecha no disponible";
        }
    }
}

window.customElements.define("x-time", Time);