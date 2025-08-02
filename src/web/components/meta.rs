use magik_macro::template;

#[template(path = "./web/components/meta.mk")]
pub struct Meta<'a> {
    pub title: &'a str,
    pub description: &'a str,
    pub preview: &'a str,
}

impl Default for Meta<'_> {
    fn default() -> Self {
        Meta {
            title: "PyE Times | News",
            description: "Últimas noticias y actualizaciones de Discord PyE.",
            preview: "/images/metatag_preview.png",
        }
    }
}
