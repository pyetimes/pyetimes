<article class="article">
  <h3 class="article-headline">
    <a href="/articles/{{ props.slug }}">{{ props.title }} →</a>
  </h3>
  <p class="by">Por {{ props.author }} | <x-time timestamp="{{ props.date.and_utc().timestamp() }}" relative></x-time></p>
  <p class="article-excerpt">{{ props.excerpt }}</p>
</article>