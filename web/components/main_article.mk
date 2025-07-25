<main class="main-story">
  <h2 class="main-headline">
    <a href="/articles/{{ props.slug }}">{{ props.headline }}</a>
  </h2>
  <p class="byline">Por {{ props.author_name }}</p>
  <p class="date">{{ 
    match props.date {
      Some(date) => format!("Publicado el <x-time timestamp=\"{}\"></x-time>", date.and_utc().timestamp()),
      None => format!("No publicado ({}).", props.id)
    } 
  }}</p>
  <p class="lead-text">{{ props.lead_text }}</p>
</main>