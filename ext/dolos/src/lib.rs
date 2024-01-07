use std::cell::RefCell;
use std::io::Read;
use magnus::{method, prelude::*, Error, Ruby, RRegexp};


#[derive(Default)]
struct StringIORust {
    chars: Vec<char>,
    char_cursor: CursorPos,
    backup: Option<CursorPos>,
}

type HowManyRead = usize;
type CursorPos = usize;

#[derive(Default)]
#[magnus::wrap(class = "StringIORust", free_immediately, size)]
struct MutStringIORust(RefCell<StringIORust>);

impl MutStringIORust {
    fn initialize(&self, input: String) {
        let mut this = self.0.borrow_mut();
        this.chars = input.chars().collect();
        this.char_cursor = 0;
        this.backup = None;
    }

    fn mark_offset(&self) {
        let mut this = self.0.borrow_mut();

        this.backup = Some(this.char_cursor);
    }

    fn rollback(&self) {
        let mut this = self.0.borrow_mut();

        if let Some(backup) = this.backup {
            this.char_cursor = backup;
        }
    }

    fn read(&self, char_count: usize) -> Result<(String, HowManyRead), std::io::Error> {
        let mut this = self.0.borrow_mut();
        let current_pos = this.char_cursor;

        if current_pos + char_count > this.chars.len() {
            return Err(std::io::Error::new(std::io::ErrorKind::InvalidInput, "Out of range"));
        }

        let end_pos = current_pos + char_count;
        this.char_cursor = end_pos;
        let result: String = this.chars[current_pos..end_pos].iter().collect();

        Ok((result, char_count))
    }

    fn read_ruby(&self, char_count: usize) -> (String, usize) {
        self.read(char_count).unwrap_or_default()
    }

    fn advance(&self, char_count: usize) {
        let mut this = self.0.borrow_mut();

        this.char_cursor = usize::min(this.chars.len(), this.char_cursor + char_count);
    }

    fn matches(&self, utf8_str: String) -> bool {
        let this = self.0.borrow();

        let current_pos = this.char_cursor;
        let end_pos = current_pos + utf8_str.chars().count();

        if end_pos > this.chars.len() {
            return false;
        }

        let substring: String = this.chars[current_pos..end_pos].iter().collect();
        substring == utf8_str
    }

    fn matches_regex(&self, pattern: RRegexp) -> String {
        let this = self.0.borrow();

        let current_pos = this.char_cursor;
        let end_pos = this.chars.len();

        if current_pos >= end_pos {
            return "".to_string();
        }

        let substring: String = this.chars[current_pos..end_pos].iter().collect();
        let re = regex::Regex::new(&pattern.to_string()).unwrap();

        if let Some(captures) = re.captures(&substring) {
            let matched = captures.get(0).unwrap().as_str();
            matched.to_string()
        } else {
            "".to_string()
        }
    }

    fn offset(&self) -> usize {
        let this = self.0.borrow();
        this.char_cursor
    }

    fn take(&self, from: CursorPos, to: CursorPos) -> Result<String, std::io::Error> {
        let this = self.0.borrow();

        if from >= this.chars.len() || to > this.chars.len() || from > to {
            return Err(std::io::Error::new(std::io::ErrorKind::InvalidInput, "Out of range"));
        }

        let slice: String = this.chars[from..to].iter().collect();
        Ok(slice)
    }

    fn take_ruby(&self, from: CursorPos, to: CursorPos) -> String {
        self.take(from, to).unwrap_or_default()
    }

    fn backup_ruby(&self) -> usize {
        let mut this = self.0.borrow_mut();

        if let Some(backup) = this.backup {
            backup
        } else {
            0
        }
    }
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let class = ruby.define_class("StringIORust", ruby.class_object()).unwrap();
    class.define_alloc_func::<MutStringIORust>();
    class.define_method("initialize", method!(MutStringIORust::initialize, 1))?;
    class.define_method("mark_offset", method!(MutStringIORust::mark_offset, 0))?;
    class.define_method("rollback", method!(MutStringIORust::rollback, 0))?;
    class.define_method("read", method!(MutStringIORust::read_ruby, 1))?;
    class.define_method("advance", method!(MutStringIORust::advance, 1))?;
    class.define_method("matches?", method!(MutStringIORust::matches, 1))?;
    class.define_method("offset", method!(MutStringIORust::offset, 0))?;
    class.define_method("take", method!(MutStringIORust::take_ruby, 2))?;
    class.define_method("backup", method!(MutStringIORust::backup_ruby, 0))?;
    class.define_method("matches_regex?", method!(MutStringIORust::matches_regex, 1))?;
    Ok(())
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_read() {
        let mut_string_io_rust = MutStringIORust::default();
        mut_string_io_rust.initialize("Hello, ąčę!".to_string());

        let (read_str, len) = mut_string_io_rust.read(8).unwrap();
        assert_eq!(read_str, "Hello, ą");
        assert_eq!(len, 8);

        let (read_again, len) = mut_string_io_rust.read(1).unwrap();

        assert_eq!(read_again, "č");
        assert_eq!(len, 1);
    }

    #[test]
    fn test_advance() {
        let mut_string_io_rust = MutStringIORust::default();
        mut_string_io_rust.initialize("š!ę".to_string());

        mut_string_io_rust.advance(1);
        let (peeked_str, _) = mut_string_io_rust.read(2).unwrap();
        assert_eq!(peeked_str, "!ę");
    }

    #[test]
    fn test_take() {
        let mut_string_io_rust = MutStringIORust::default();
        mut_string_io_rust.initialize("š!ę".to_string());

        let take_str = mut_string_io_rust.take(0, 2).unwrap();
        assert_eq!(take_str, "š!");
    }
}