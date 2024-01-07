use std::cell::RefCell;
use std::io::{Cursor, Read};
use std::str;
use magnus::{method,
             prelude::*,
             Error, Ruby,
};


#[derive(Default)]
struct StringIO {
    cursor: Cursor<Vec<u8>>,
    offset: usize,
    backup: Option<usize>,
}

#[derive(Default)]
#[magnus::wrap(class = "StringIO", free_immediately, size)]
struct MutStringIO(RefCell<StringIO>);

impl MutStringIO {
    fn initialize(&self, input: String) {
        let mut this = self.0.borrow_mut();
        this.offset = 0;
        this.backup = None;
        this.cursor = Cursor::new(input.into_bytes());
    }

    fn mark_offset(&self) {
        let mut this = self.0.borrow_mut();

        this.backup = Some(this.offset);
    }

    fn rollback(&self) {
        let mut this = self.0.borrow_mut();

        if let Some(backup) = this.backup {
            this.offset = backup;
            this.cursor.set_position(backup as u64);
        }
    }

    fn peek(&self, mut bytesize: usize) -> Option<(String, usize)> {
        let mut this = self.0.borrow_mut();
        let mut buffer = vec![0; bytesize];

        match this.cursor.read_exact(&mut buffer) {
            Ok(_) => {
                while !str::from_utf8(&buffer).is_ok() && bytesize < 4 {
                    bytesize += 1;
                    buffer.push(0);
                    this.cursor.read_exact(&mut buffer[bytesize - 1..bytesize]).ok()?;
                }
                let offset = this.offset;
                this.cursor.set_position(offset as u64);
                Some((String::from_utf8_lossy(&buffer).to_string(), bytesize))
            }
            Err(_) => None,
        }
    }

    fn peek_ruby(&self, bytesize: usize) -> (String, usize) {
        self.peek(bytesize).unwrap_or_default()
    }

    fn advance(&self, bytesize: usize) {
        let mut this = self.0.borrow_mut();

        this.offset += bytesize;
        let offset = this.offset as u64;
        this.cursor.set_position(offset);
    }

    fn matches(&self, utf8_str: String) -> bool {
        let mut buffer = vec![0; utf8_str.len()];
        let mut this = self.0.borrow_mut();

        let offset = this.offset as u64;

        match this.cursor.read_exact(&mut buffer) {
            Ok(_) => {
                this.cursor.set_position(offset);
                buffer == utf8_str.as_bytes()
            }
            Err(_) => false,
        }
    }
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let class = ruby.define_class("StringIO", ruby.class_object()).unwrap();
    class.define_alloc_func::<MutStringIO>();
    class.define_method("initialize", method!(MutStringIO::initialize, 1))?;
    class.define_method("mark_offset", method!(MutStringIO::mark_offset, 0))?;
    class.define_method("rollback", method!(MutStringIO::rollback, 0))?;
    class.define_method("peek", method!(MutStringIO::peek_ruby, 1))?;
    class.define_method("advance", method!(MutStringIO::advance, 1))?;
    class.define_method("matches", method!(MutStringIO::matches, 1))?;
    Ok(())
}