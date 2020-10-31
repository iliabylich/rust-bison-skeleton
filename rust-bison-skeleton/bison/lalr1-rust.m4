# Rust skeleton for Bison                           -*- autoconf -*-

# Copyright (C) 2007-2015, 2018-2020 Free Software Foundation, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

m4_include(b4_skeletonsdir/[rust.m4])

b4_defines_if([b4_complain([%defines does not make sense in Rust])])

m4_define([b4_symbol_no_destructor_assert],
[b4_symbol_if([$1], [has_destructor],
              [b4_complain_at(m4_unquote(b4_symbol([$1], [destructor_loc])),
                              [%destructor does not make sense in Rust])])])
b4_symbol_foreach([b4_symbol_no_destructor_assert])

# Define a macro to encapsulate the parse state variables.
m4_define([b4_define_state],[[
    /* Lookahead token kind.  */
    let mut yychar: i32 = Self::YYEMPTY_;
    /* Lookahead symbol kind.  */
    let mut yytoken: SymbolKind = SymbolKind { value: 0 };

    /* State.  */
    let mut yyn: i32 = 0;
    let mut yylen: usize = 0;
    let mut yystate: i32 = 0;
    let mut yystack = YYStack::new();
    let mut label: i32 = Self::YYNEWSTATE;

]b4_locations_if([[
    /* The location where the error started.  */
    let mut yyerrloc: ]b4_location_type[ = ]b4_location_type[ { begin: 0, end: 0};

    /* Location. */
    let mut yylloc: ]b4_location_type[ = ]b4_location_type[ { begin: 0, end: 0 };]])[

    /* Semantic value of the lookahead.  */
    let mut yylval: ]b4_yystype[ = ]b4_yystype[::None;
]])[

]b4_output_begin([b4_parser_file_name])[
]b4_copyright([Skeleton implementation for Bison LALR(1) parsers in Rust],
              [2007-2015, 2018-2020])[
]b4_disclaimer[
]b4_percent_define_ifdef([api.package], [package b4_percent_define_get([api.package]);[
]])[
]b4_user_pre_prologue[
]b4_user_post_prologue[
use std::convert::TryInto;

]
b4_percent_code_get([[use]])[

/**
 * A Bison parser, automatically generated from <tt>]m4_bpatsubst(b4_file_name, [^"\(.*\)"$], [\1])[</tt>.
 */
][
#@{derive(Debug)@}
pub struct ]b4_parser_struct[ {
    pub yylexer: Lexer,
    // true if verbose error messages are enabled.
    #[allow(dead_code)]
    yy_error_verbose: bool,
    // number of errors so far
    yynerrs: i32,

    pub yydebug: bool,

    yyerrstatus_: i32,

    ]b4_percent_code_get([[parser_fields]])[
}

#[inline]
fn usize_to_i32(v: usize) -> i32 {
    v.try_into().unwrap()
}

#[inline]
fn i32_to_usize(v: i32) -> usize {
    v.try_into().unwrap()
}

#[derive(Debug, Clone)]
pub enum TokenValue {
    String(String),
    InvalidString(Vec<u8>),
}
impl TokenValue {
    pub fn to_string_lossy(&self) -> String {
        match &self {
            Self::String(s) => s.clone(),
            Self::InvalidString(bytes) => String::from_utf8_lossy(&bytes).into_owned(),
        }
    }

    pub fn to_bytes(&self) -> Vec<u8> {
        match &self {
            Self::String(s) => s.as_bytes().to_vec(),
            Self::InvalidString(bytes) => bytes.clone(),
        }
    }
}

#[derive(Debug, Clone)]
pub struct Token {
    pub token_type: i32,
    pub token_value: TokenValue,
    ]b4_locations_if([pub loc: ]b4_location_type)[
}

impl Token {
    pub fn to_string_lossy(&self) -> String {
        self.token_value.to_string_lossy()
    }

    pub fn to_bytes(&self) -> Vec<u8> {
        self.token_value.to_bytes()
    }
}

#[derive(Debug, Clone, PartialEq)]
pub struct ]b4_location_type[ {
    pub begin: usize,
    pub end: usize,
}

impl ]b4_location_type[ {
    pub fn to_range(&self) -> std::ops::Range<usize> {
        self.begin..self.end
    }
}

impl ]b4_parser_struct[ {]
b4_identification[]
[}]

b4_parse_error_bmatch(
           [detailed\|verbose], [[
impl ]b4_parser_struct[ {
    /**
    * Whether verbose error messages are enabled.
    */
    pub(crate) fn error_verbose(&self) -> bool { self.yy_error_verbose }

    /**
    * Set the verbosity of error messages.
    * @@param verbose True to request verbose error messages.
    */
    pub(crate) fn set_error_verbose(&mut self, verbose: bool) {
        self.yy_error_verbose = verbose;
    }
}
]])
[
fn make_yylloc(rhs: &YYStack, n: usize) -> ]b4_location_type[ {
    if 0 < n {
        ]b4_location_type[ { begin: rhs.location_at(n - 1).begin, end: rhs.location_at(0).end }
    } else {
        ]b4_location_type[ { begin: rhs.location_at(0).end, end: rhs.location_at(0).end }
    }
}
]

b4_declare_symbol_enum[

// Communication interface between the scanner and the Bison-generated
// parser <tt>]b4_parser_struct[</tt>.
impl Lexer {
]b4_token_enums[

    // Deprecated, use ]b4_symbol(0, id)[ instead.
    #@{allow(dead_code)@}
    const EOF: i32 = Self::]b4_symbol(0, id)[;

    // Token values
    #@{allow(dead_code)@}
][pub(crate) const TOKEN_NAMES: &'static [&'static str] = &]b4_token_values[;
}
]

[impl ]b4_parser_struct[ {]

b4_parse_trace_if([[
]])[

]b4_locations_if([[
  ]])[
]b4_parse_trace_if([[
  fn yycdebug(&self, s: &str) {
    if self.yydebug {
        eprintln!("{}", s);
    }
  }]])[

}

#[derive(Clone, Debug)]
pub struct YYStack {
    state_stack: Vec<i32>,
    loc_stack: Vec<]b4_location_type[>,
    value_stack: Vec<]b4_yystype[>,
}

impl YYStack {
    pub(crate) fn new() -> Self {
        Self {
          state_stack: vec![],
          loc_stack: vec![],
          value_stack: vec![],
        }
    }

    pub(crate) fn push(&mut self, state: i32, value: ]b4_yystype[]b4_locations_if([, loc: ]b4_location_type)[) {
        self.state_stack.push(state);
        ]b4_locations_if([[
        self.loc_stack.push(loc);
        ]])[
        self.value_stack.push(value);
    }

    pub(crate) fn pop(&mut self) {
        self.pop_n(1);
    }

    pub(crate) fn pop_n(&mut self, num: usize) {
        for _ in 0..num {
          self.state_stack.pop();
          ]b4_locations_if([[
          self.loc_stack.pop();
          ]])[
          self.value_stack.pop();
        }
    }

    pub(crate) fn state_at(&self, i: usize) -> i32 {
        self.state_stack[self.len() - 1 - i]
    }
]b4_locations_if([[

    pub(crate) fn location_at(&self, i: usize) -> &]b4_location_type[ {
        &self.loc_stack[self.len() - 1 - i]
    }
]])[
    pub(crate) fn borrow_value_at(&self, i: usize) -> &]b4_yystype[ {
        &self.value_stack[self.len() - 1 - i]
    }

    pub(crate) fn owned_value_at(&mut self, i: usize) ->]b4_yystype[ {
        let len = self.len();
        std::mem::replace(&mut self.value_stack[len - 1 - i], ]b4_yystype[::Stolen)
    }

    pub(crate) fn len(&self) -> usize {
      self.state_stack.len()
    }

}

impl std::fmt::Display for YYStack {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let state = self.state_stack.iter().map(|e| e.to_string()).collect::<Vec<String>>().join(" ");
        f.write_fmt(format_args!("Stack now {}", state))
    }
}

impl ]b4_parser_struct[ {
  /**
   * Returned by a Bison action in order to stop the parsing process and
   * return success (<tt>true</tt>).
   */
  pub(crate) const YYACCEPT: i32 = 0;

  /**
   * Returned by a Bison action in order to stop the parsing process and
   * return failure (<tt>false</tt>).
   */
  pub(crate) const YYABORT: i32 = 1;

][

  /**
   * Returned by a Bison action in order to start error recovery without
   * printing an error message.
   */
  pub(crate) const YYERROR: i32 = 2;

  /**
   * Internal return codes that are not supported for user semantic
   * actions.
   */
  pub(crate) const YYERRLAB: i32 = 3;
  pub(crate) const YYNEWSTATE: i32 = 4;
  pub(crate) const YYDEFAULT: i32 = 5;
  pub(crate) const YYREDUCE: i32 = 6;
  pub(crate) const YYERRLAB1: i32 = 7;
  #@{allow(dead_code)@}
  pub(crate) const YYRETURN: i32 = 8;
][

][
  /**
   * Whether error recovery is being done.  In this state, the parser
   * reads token until it reaches a known state, and then restarts normal
   * operation.
   */
  #@{allow(dead_code)@}
  pub(crate) fn recovering(&self) -> bool {
      self.yyerrstatus_ == 0
  }

    /** Compute post-reduction state.
    * @@param yystate   the current state
    * @@param yysym     the nonterminal to push on the stack
    */
    fn yy_lr_goto_state(&self, yystate: i32, yysym: usize) -> i32 {
        let yysym = usize_to_i32(yysym);
        let idx = i32_to_usize(yysym - Self::YYNTOKENS_);
        let yyr = Self::yypgoto_[idx] + yystate;
        if 0 <= yyr && yyr <= Self::YYLAST_ {
            let yyr = i32_to_usize(yyr);
            if Self::yycheck_[yyr] == yystate {
                return Self::yytable_[yyr];
            }
        }
        Self::yydefgoto_[idx]
    }

  fn yyaction(&mut self, yyn: i32, yystack: &mut YYStack, yylen: &mut usize) -> Result<i32, ]b4_parse_error_type[> {][
    /* If YYLEN is nonzero, implement the default value of the action:
       '$$ = $1'.  Otherwise, use the top of the stack.

       Otherwise, the following line sets YYVAL to garbage.
       This behavior is undocumented and Bison
       users should not rely upon it.  */
    #@{allow(unused_assignments)@}
    let mut yyval: ]b4_yystype[ = ]b4_yystype[::None;
    ]b4_locations_if([[
    let yyloc: ]b4_location_type[ = make_yylloc(&yystack, *yylen);]])[]b4_parse_trace_if([[

    self.yy_reduce_print(yyn, yystack);]])[

    match yyn {
        ]b4_user_actions[
        _ => {}
    }]b4_parse_trace_if([[

    if let ]b4_yystype[::None = yyval {
        yyval = if 0 < *yylen {
            yystack.borrow_value_at(*yylen - 1).clone()
        } else {
            yystack.borrow_value_at(0).clone()
        }
    }

    self.yy_symbol_print("-> $$ =", SymbolKind::get(Self::yyr1_[i32_to_usize(yyn)]), &yyval]b4_locations_if([, &yyloc])[);]])[

    yystack.pop_n(*yylen);
    *yylen = 0;
    /* Shift the result of the reduction.  */
    let yystate = self.yy_lr_goto_state(yystack.state_at(0), Self::yyr1_[i32_to_usize(yyn)]);
    yystack.push(yystate, yyval]b4_locations_if([, yyloc])[);
    Ok(Self::YYNEWSTATE)
  }

]b4_parse_trace_if([[
  /*--------------------------------.
  | Print this symbol on YYOUTPUT.  |
  `--------------------------------*/

  fn yy_symbol_print(&self, s: &str, yykind: &SymbolKind,
                             yyvalue: &]b4_yystype[]b4_locations_if([, yylocation: &]b4_location_type[])[) {
      if self.yydebug {
          self.yycdebug(
            &format!("{}{} {:?} ( {:?}: {:?} )",
              s,
              if yykind.code() < Self::YYNTOKENS_ { " token " } else { " nterm " },
              yykind.name(),
              ]b4_locations_if([yylocation,])[
              yyvalue
            )
          )
      }
  }]])[

][
  /**
   * Parse input from the scanner that was specified at object construction
   * time.  Return whether the end of the input was reached successfully.
   *
   * @@return <tt>true</tt> if the parsing succeeds.  Note that this does not
   *          imply that there were no syntax errors.
   */
  pub fn parse(&mut self) -> bool][
][
  {]b4_locations_if([[
    /* @@$.  */
    let mut yyloc: ]b4_location_type[;]])[
][
]b4_define_state[]b4_parse_trace_if([[
    self.yycdebug("Starting parse");]])[
    self.yyerrstatus_ = 0;
    self.yynerrs = 0;

    /* Initialize the stack.  */
    yystack.push(yystate, yylval.clone()]b4_locations_if([, yylloc.clone()])[);
]m4_ifdef([b4_initial_action], [
b4_dollar_pushdef([yylval], [], [], [yylloc])dnl
    b4_user_initial_action
b4_dollar_popdef[]dnl
])[
][
][
    loop {
      match label {
        /* New state.  Unlike in the C/C++ skeletons, the state is already
           pushed when we come here.  */

      Self::YYNEWSTATE => {]b4_parse_trace_if([[
        self.yycdebug(&format!("Entering state {}", yystate));
        if self.yydebug { eprintln!("{}", yystack) }]])[

        /* Accept? */
        if yystate == Self::YYFINAL_ {
          return true;
        }

        /* Take a decision.  First try without lookahead.  */
        yyn = Self::yypact_[i32_to_usize(yystate)];
        if yy_pact_value_is_default(yyn) {
          label = Self::YYDEFAULT;
          continue;
        }

        /* Read a lookahead token.  */
        if yychar == Self::YYEMPTY_ {
]b4_parse_trace_if([[
            self.yycdebug("Reading a token");]])[
            let token = self.next_token();
            yychar = token.token_type;]b4_locations_if([[
            yylloc = token.loc.clone();]])[
            yylval = ]b4_yystype[::from_token(token);
][
          }

        /* Convert token to internal form.  */
        yytoken = Self::yytranslate_(yychar);]b4_parse_trace_if([[
        self.yy_symbol_print("Next token is", &yytoken,
                      &yylval]b4_locations_if([, &yylloc])[);]])[

        if yytoken == (]b4_symbol(1, kind)[) {
            // The scanner already issued an error message, process directly
            // to error recovery.  But do not keep the error token as
            // lookahead, it is too special and may lead us to an endless
            // loop in error recovery. */
            yychar = Lexer::]b4_symbol(2, id)[;
            yytoken = ]b4_symbol(2, kind)[;]b4_locations_if([[
            yyerrloc = yylloc.clone();]])[
            label = Self::YYERRLAB1;
        } else {
            /* If the proper action on seeing token YYTOKEN is to reduce or to
               detect an error, take that action.  */
            yyn += yytoken.code();
            if yyn < 0 || Self::YYLAST_ < yyn || Self::yycheck_[i32_to_usize(yyn)] != yytoken.code() {
              label = Self::YYDEFAULT;
            }

            /* <= 0 means reduce or error.  */
            else {
              yyn = Self::yytable_[i32_to_usize(yyn)];
              if yyn <= 0 {
                if yy_table_value_is_error(yyn) {
                  label = Self::YYERRLAB;
                } else {
                  yyn = -yyn;
                  label = Self::YYREDUCE;
                }
              } else {
                /* Shift the lookahead token.  */]b4_parse_trace_if([[
                self.yy_symbol_print("Shifting", &yytoken,
                              &yylval]b4_locations_if([, &yylloc])[);
]])[
                /* Discard the token being shifted.  */
                yychar = Self::YYEMPTY_;

                /* Count tokens shifted since error; after three, turn off error
                   status.  */
                if self.yyerrstatus_ > 0 {
                  self.yyerrstatus_ -= 1;
                }

                yystate = yyn;
                yystack.push(yystate, yylval.clone()]b4_locations_if([, yylloc.clone()])[);
                label = Self::YYNEWSTATE;
              }
            }
          }
        continue;
      }, // YYNEWSTATE
][


      /*-----------------------------------------------------------.
      | yydefault -- do the default action for the current state.  |
      `-----------------------------------------------------------*/
      Self::YYDEFAULT => {
        yyn = usize_to_i32(Self::yydefact_[i32_to_usize(yystate)]);
        if yyn == 0 {
          label = Self::YYERRLAB;
        } else {
          label = Self::YYREDUCE;
        }
        continue;
      } // YYDEFAULT

      /*-----------------------------.
      | yyreduce -- Do a reduction.  |
      `-----------------------------*/
      Self::YYREDUCE => {
        yylen = Self::yyr2_[i32_to_usize(yyn)];
        label = match self.yyaction(yyn, &mut yystack, &mut yylen) {
            Ok(label) => label,
            Err(_) => Self::YYERROR
        };
        yystate = yystack.state_at(0);
        continue;
      }, // YYREDUCE

      /*------------------------------------.
      | yyerrlab -- here on detecting error |
      `------------------------------------*/
      Self::YYERRLAB => {
        /* If not already recovering from an error, report this error.  */
        if self.yyerrstatus_ == 0 {
            self.yynerrs += 1;
            if yychar == Self::YYEMPTY_ {
              yytoken = SymbolKind { value: 0 };
            }
            self.report_syntax_error(&Context::new(yystack.clone(), yytoken.clone()]b4_locations_if([[, yylloc.clone()]])[));
          }
]b4_locations_if([[
        yyerrloc = yylloc.clone();]])[
        if self.yyerrstatus_ == 3 {
            /* If just tried and failed to reuse lookahead token after an
               error, discard it.  */

            if yychar <= Lexer::]b4_symbol(0, id)[ {
                /* Return failure if at end of input.  */
                if yychar == Lexer::]b4_symbol(0, id)[ {
                  return false;
                }
              }
            else {
              yychar = Self::YYEMPTY_;
            }
          }

        /* Else will try to reuse lookahead token after shifting the error
           token.  */
        label = Self::YYERRLAB1;
        continue;
      }, // YYERRLAB

      /*-------------------------------------------------.
      | errorlab -- error raised explicitly by YYERROR.  |
      `-------------------------------------------------*/
      Self::YYERROR => {
        /* Do not reclaim the symbols of the rule which action triggered
           this YYERROR.  */
        yystack.pop_n(yylen);
        yylen = 0;
        yystate = yystack.state_at(0);
        label = Self::YYERRLAB1;
        continue;
      }, // YYERROR

      /*-------------------------------------------------------------.
      | yyerrlab1 -- common code for both syntax error and YYERROR.  |
      `-------------------------------------------------------------*/
      Self::YYERRLAB1 => {
        self.yyerrstatus_ = 3;       /* Each real token shifted decrements this.  */

        // Pop stack until we find a state that shifts the error token.
        loop {
            yyn = Self::yypact_[i32_to_usize(yystate)];
            if !yy_pact_value_is_default(yyn) {
                yyn += SymbolKind { value: SymbolKind::S_YYerror }.code();
                if 0 <= yyn && yyn <= Self::YYLAST_ {
                  let yyn_usize = i32_to_usize(yyn);
                  if Self::yycheck_[yyn_usize] == SymbolKind::S_YYerror {
                    yyn = Self::yytable_[yyn_usize];
                    if 0 < yyn {
                      break;
                    }
                  }
                }
            }

            /* Pop the current state because it cannot handle the
             * error token.  */
            if yystack.len() == 1 {
              return false;
            }

]b4_locations_if([[
            yyerrloc = yystack.location_at(0).clone();]])[
            yystack.pop();
            yystate = yystack.state_at(0);]b4_parse_trace_if([[
            if self.yydebug {
              eprintln!("{}", yystack);]])[
            }
          }

        if label == Self::YYABORT {
          /* Leave the switch.  */
          continue;
        }

]b4_locations_if([[
        /* Muck with the stack to setup for yylloc.  */
        yystack.push(0, ]b4_yystype[::None, yylloc.clone());
        yystack.push(0, ]b4_yystype[::None, yyerrloc.clone());
        yyloc = make_yylloc(&yystack, 2);
        yystack.pop_n(2);]])[

        /* Shift the error token.  */]b4_parse_trace_if([[
        self.yy_symbol_print("Shifting", SymbolKind::get(Self::yystos_[i32_to_usize(yyn)]),
                      &yylval]b4_locations_if([, &yyloc])[);]])[

        yystate = yyn;
        yystack.push(yyn, yylval.clone()]b4_locations_if([, yyloc.clone()])[);
        label = Self::YYNEWSTATE;
        continue;
      }, // YYERRLAB1

        /* Accept.  */
      Self::YYACCEPT => {
        ][
      }, // YYACCEPT

        /* Abort.  */
      Self::YYABORT => {
        ][
      }, // YYABORT

      _ => {
        panic!("internal bison error: unknown label {}", label);
      }
      }
    }
}
}
][

][

#@{derive(Debug)@}
pub(crate) struct Context {
    yystack: YYStack,
    yytoken: SymbolKind,
    loc: ]b4_location_type[
}

impl Context {
    pub(crate) fn new(stack: YYStack, token: SymbolKind, loc: ]b4_location_type[) -> Self {
        Self { yystack: stack, yytoken: token, loc }
    }

    #@{allow(dead_code)@}
    pub(crate) fn token(&self) -> &SymbolKind {
        &self.yytoken
    }

    #@{allow(dead_code)@}
    pub(crate) fn location(&self) -> &]b4_location_type[ {
        &self.loc
    }
}

][

/**
  * Whether the given <code>yypact_</code> value indicates a defaulted state.
  * @@param yyvalue   the value to check
  */
fn yy_pact_value_is_default(yyvalue: i32) -> bool {
    yyvalue == YYPACT_NINF_
}

/**
  * Whether the given <code>yytable_</code>
  * value indicates a syntax error.
  * @@param yyvalue the value to check
  */
fn yy_table_value_is_error(yyvalue: i32) -> bool {
    yyvalue == YYTABLE_NINF_
}

const YYPACT_NINF_: ]b4_int_type_for([b4_pact])[ = ]b4_pact_ninf[;
const YYTABLE_NINF_: ]b4_int_type_for([b4_table])[ = ]b4_table_ninf[;

impl ]b4_parser_struct[ {

]b4_parser_tables_define[

]b4_parse_trace_if([[
  ]b4_integral_parser_table_define([rline], [b4_rline],
  [[YYRLINE[YYN] -- Source line where rule number YYN was defined.]])[


  // Report on the debug stream that the rule yyrule is going to be reduced.
  fn yy_reduce_print(&self, yyrule: i32, yystack: &YYStack) {
    if !self.yydebug {
      return;
    }

    let yylno = Self::yyrline_[i32_to_usize(yyrule)];
    let yynrhs = Self::yyr2_[i32_to_usize(yyrule)];
    /* Print the symbols being reduced, and their result.  */
    self.yycdebug(&format!("Reducing stack by rule {} (line {}):", yyrule - 1,
              yylno));

    /* The symbols being reduced.  */
    for yyi in 0..yynrhs {
      let state: usize = i32_to_usize(yystack.state_at(yynrhs - (yyi + 1)));
      self.yy_symbol_print(&format!("   ${} =", yyi + 1),
                    SymbolKind::get(Self::yystos_[state]),
                    yystack.borrow_value_at(yynrhs - (yyi + 1))]b4_locations_if([,
                    yystack.location_at(yynrhs - (yyi + 1))])[);
    }
  }]])[

  /* YYTRANSLATE_(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
     as returned by yylex, with out-of-bounds checking.  */
  fn yytranslate_(t: i32) -> SymbolKind
]b4_api_token_raw_if(dnl
[[  {
    return SymbolKind::get(t);
  }
]],
[[  {
    // Last valid token kind.
    let code_max: i32 = ]b4_code_max[;
      if t <= 0 {
          ]b4_symbol(0, kind)[
      } else if t <= code_max {
        let t = i32_to_usize(t);
          SymbolKind::get(Self::yytranslate_table_[t]).clone()
      } else {
          ]b4_symbol(2, kind)[
      }
  }
  ]b4_integral_parser_table_define([translate_table], [b4_translate])[
]])[

const YYLAST_: i32 = ]b4_last[;
const YYEMPTY_: i32 = -2;
const YYFINAL_: i32 = ]b4_final_state_number[;
const YYNTOKENS_: i32 = ]b4_tokens_number[;
}

]b4_percent_code_get[

]b4_percent_code_get([[epilogue]])[]dnl
b4_epilogue[]dnl
b4_output_end
