use std::path;

use crate::template::Template;

mod parser;
mod template;

pub fn from_string(input: &str) -> Template {
    Template::from_string(input)
        .map_err(|e| format!("Failed to load template from string: {}", e))
        .unwrap()
}

pub fn get(path: &str) -> Template {
    Template::from_file(path)
        .map_err(|e| format!("Failed to load template from '{}': {}", path, e))
        .unwrap()
}

pub fn build(path: &str) -> Result<(), String> {
    let template_path = path::Path::new(path);
    if !template_path.exists() {
        return Err(format!("Template path '{}' does not exist", path));
    }
    Ok(())
}

mod test {
    use super::*;

    #[test]
    fn test_from_str() {
        let result = from_string("<h1>Hello, World!</h1>");
        println!("Result: {}", result.render());
        assert!(result.render() == "<h1>Hello, World!</h1>");
    }
}
