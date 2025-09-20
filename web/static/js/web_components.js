class Time extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    const timestamp = this.getAttribute("timestamp");

    let date = new Date();

    if (timestamp) {
      date = new Date(parseInt(timestamp, 10) * 1000);

      if (date === "Invalid Date" || isNaN(date.getTime())) {
        this.textContent = "Fecha no válida";
        return;
      }
    }

    const relative = this.getAttribute("relative");

    if (relative !== null) {
      const now = new Date();
      const diff = Math.floor((now - date) / 1000); // diferencia en segundos

      let timeString = "";

      if (diff < 60) {
        timeString = "Hace unos segundos";
      } else if (diff < 3600) {
        const minutes = Math.floor(diff / 60);
        timeString = `Hace ${minutes} minuto${minutes !== 1 ? "s" : ""}`;
      } else if (diff < 86400) {
        const hours = Math.floor(diff / 3600);
        timeString = `Hace ${hours} hora${hours !== 1 ? "s" : ""}`;
      } else {
        const days = Math.floor(diff / 86400);
        timeString = `Hace ${days} día${days !== 1 ? "s" : ""}`;
      }

      this.textContent = timeString;
      return;
    }

    this.textContent = date.toLocaleDateString("es-ES", {
      weekday: "long",
      year: "numeric",
      month: "long",
      day: "numeric",
    });

    this.textContent =
      this.textContent[0].toUpperCase() + this.textContent.slice(1);
  }
}

window.customElements.define("x-time", Time);
