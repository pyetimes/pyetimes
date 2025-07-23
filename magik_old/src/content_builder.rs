pub struct ContentBuilder {
    content: Vec<String>,
    end: String,
}

impl ContentBuilder {
    pub fn new() -> Self {
        ContentBuilder {
            content: Vec::new(),
            end: String::from("\n"),
        }
    }

    pub fn add(&mut self, value: String) {
        self.content.push(value);
    }

    pub fn set_end(&mut self, end: String) {
        self.end = end;
    }

    pub fn build(&self) -> String {
        self.content.join(&self.end)
    }
}
