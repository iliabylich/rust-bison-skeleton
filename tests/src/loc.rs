///
#[derive(Clone, PartialEq, Eq, Copy)]
#[repr(C)]
pub struct Loc {
    /// Begin of the `Loc` range
    pub begin: u32,
    /// End of the `Loc` range
    pub end: u32,
}

impl Loc {
    /// Converts location to a range
    pub fn to_range(&self) -> std::ops::Range<u32> {
        self.begin..self.end
    }
}

impl Default for Loc {
    fn default() -> Self {
        Self { begin: 0, end: 0 }
    }
}
