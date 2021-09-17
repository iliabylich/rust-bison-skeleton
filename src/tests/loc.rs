///
#[derive(Clone, PartialEq, Eq, Default)]
#[repr(C)]
pub struct Loc {
    /// Begin of the `Loc` range
    begin: u32,
    /// End of the `Loc` range
    end: u32,
}

impl Loc {
    /// Constructs a new Loc with given begin/end
    pub fn new(begin: u32, end: u32) -> Self {
        Self { begin, end }
    }

    /// Returns begin of the loc range
    pub fn begin(&self) -> u32 {
        self.begin
    }

    /// Returns end of the loc range
    pub fn end(&self) -> u32 {
        self.end
    }

    /// Converts location to a range
    pub fn to_range(&self) -> std::ops::Range<u32> {
        self.begin..self.end
    }
}

impl std::fmt::Debug for Loc {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_ /*'*/>) -> Result<(), std::fmt::Error> {
        f.write_str(&format!("{}...{}", self.begin, self.end))
    }
}
