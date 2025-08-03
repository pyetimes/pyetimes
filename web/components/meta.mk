<title>{{ props.title }}</title>
<meta name="title" content="{{ props.title }}" />
<meta
    name="description"
    content="{{ props.description }}"
/>

<!-- Open Graph / Facebook -->
<meta property="og:type" content="website" />
<meta property="og:url" content="https://pyetimes.daril.dev/" />
<meta property="og:title" content="{{ props.title }}" />
<meta
    property="og:description"
    content="{{ props.description }}"
/>
<meta property="og:image" content="{{ props.preview }}" />

<!-- Twitter -->
<meta property="twitter:card" content="summary_large_image" />
<meta property="twitter:url" content="https://pyetimes.daril.dev/" />
<meta property="twitter:title" content="{{ props.title }}" />
<meta
    property="twitter:description"
    content="{{ props.description }}"
/>
<meta property="twitter:image" content="{{ props.preview }}" />

<!-- Favicon -->
<link rel="icon" type="image/png" href="/favicon.png" />