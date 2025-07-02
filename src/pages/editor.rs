use serde_json::json;

use crate::{models::Article, pages::Page};

fn escape_string(s: &str) -> String {
    let escaped = json!(s).to_string();
    escaped.trim_matches('"').to_string()
}

pub fn editor(article: Option<Article>) -> Page {
    let mut layout = magik::get("./pages/editor/layout.html");

    if article.is_some() {
        let article = article.unwrap();

        layout.set("content", &escape_string(&article.content));
        layout.set("title", &escape_string(&article.title));
        layout.set("slug", &article.slug);
        layout.set("excerpt", &escape_string(&article.excerpt));
        layout.set("button_text", &"Actualizar");
        layout.set(
            "tags",
            &article
                .tags
                .iter()
                .map(|tag| escape_string(tag))
                .collect::<Vec<String>>()
                .join(", "),
        );
    } else {
        layout.set(
            "content",
            &"# Bienvenido al Editor de PyE Times\\n\\nEscribe tu artículo aquí...",
        );
        layout.set("title", &());
        layout.set("slug", &());
        layout.set("excerpt", &());
        layout.set("tags", &());
        layout.set("button_text", &"Guardar");
    }

    layout.into()
}
