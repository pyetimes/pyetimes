<main class="main-story">
  <h2 class="main-headline">
    <a href="/articles/{{ props.slug }}">{{ props.headline }} →</a>
  </h2>
  <p class="byline">Por {{ props.author_name }} | {{ format!("<x-time timestamp=\"{}\" relative></x-time>", props.date.unwrap_or_default().and_utc().timestamp()) }} </p>
  <p class="lead-text">{{ props.lead_text }}</p>
</main>