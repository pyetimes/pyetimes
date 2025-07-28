class Time extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    const timestamp = this.getAttribute("timestamp");

    let date = new Date();

    if (timestamp) {
      const date = new Date(parseInt(timestamp, 10) * 1000);

      if (date === "Invalid Date" || isNaN(date.getTime())) {
        this.textContent = "Fecha no válida";
        return;
      }
    }

    this.textContent = date.toLocaleDateString("es-ES", {
      weekday: "long",
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  }
}

window.customElements.define("x-time", Time);
