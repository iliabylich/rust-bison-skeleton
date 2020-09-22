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
    let mut yylen: i32 = 0;
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
use std::convert::TryFrom;

]
b4_percent_code_get([[use]])[
/**
 * A Bison parser, automatically generated from <tt>]m4_bpatsubst(b4_file_name, [^"\(.*\)"$], [\1])[</tt>.
 *
 * @@author LALR (1) parser skeleton written by Paolo Bonzini.
 */
][
#@{derive(Default)@}
pub struct ]b4_parser_struct[ {
    yylexer: Lexer,
    // true if verbose error messages are enabled.
    #[allow(dead_code)]
    yy_error_verbose: bool,
    // number of errors so far
    yynerrs: i32,

    pub yydebug: i32,

    yyerrstatus_: i32,

  ]b4_percent_code_get([[parser_struct_fields]])[
}

macro_rules! cast_to_variant {
    ($v:ident, $value:expr) => {
        match $value {
            ]b4_yystype[::$v(v) => v,
            _ => panic!("{:#?}", $value)
        }
    };
}

pub type Token = (i32, String]b4_locations_if([, ]b4_location_type)[);

#[derive(Debug, Clone, PartialEq)]
pub struct ]b4_location_type[ {
    pub begin: usize,
    pub end: usize,
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
    pub fn error_verbose(&self) -> bool { self.yy_error_verbose }

    /**
    * Set the verbosity of error messages.
    * @@param verbose True to request verbose error messages.
    */
    pub fn set_error_verbose(&mut self, verbose: bool) {
        self.yy_error_verbose = verbose;
    }
}
]])
[
fn make_yylloc(rhs: &YYStack, n: i32) -> ]b4_location_type[ {
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
]

[
}
]

[impl ]b4_parser_struct[ {]

b4_parse_trace_if([[
]])[

]b4_locations_if([[
  /**
   * Print an error message via the lexer.
   * @@param loc The location associated with the message.
   * @@param msg The error message.
   */
  pub fn yyerror(&mut self, loc: &]b4_location_type[, msg: &str) {
      self.yylexer.yyerror(loc, msg);
  }
  ]])[
]b4_parse_trace_if([[
  fn yycdebug(&self, s: &str) {
    if 0 < self.yydebug {
        eprintln!("{}", s);
    }
  }]])[

}

#[derive(Clone)]
struct YYStack {
    state_stack: Vec<i32>,
    loc_stack: Vec<]b4_location_type[>,
    value_stack: Vec<]b4_yystype[>,
}

impl YYStack {
    pub fn new() -> Self {
        Self {
          state_stack: vec![],
          loc_stack: vec![],
          value_stack: vec![],
        }
    }

    pub fn push(&mut self, state: i32, value: &]b4_yystype[]b4_locations_if([, loc: &]b4_location_type)[) {
        self.state_stack.push(state);
        ]b4_locations_if([[
        self.loc_stack.push(loc.clone());
        ]])[
        self.value_stack.push(value.clone());
    }

    pub fn pop(&mut self) {
        self.pop_n(1);
    }

    pub fn pop_n(&mut self, num: i32) {
        for _ in 0..num {
          self.state_stack.pop();
          ]b4_locations_if([[
          self.loc_stack.pop();
          ]])[
          self.value_stack.pop();
        }
    }

    pub fn state_at(&self, i: i32) -> &i32 {
        self.state_stack.iter().rev().nth(i.try_into().unwrap()).unwrap()
    }
]b4_locations_if([[

    pub fn location_at(&self, i: i32) -> &]b4_location_type[ {
        self.loc_stack.iter().rev().nth(i.try_into().unwrap()).unwrap()
    }
]])[
    pub fn value_at(&self, i: i32) -> &]b4_yystype[ {
        self.value_stack.iter().rev().nth(i.try_into().unwrap()).unwrap()
    }

    pub fn is_empty(&self) -> bool {
      self.state_stack.is_empty()
    }

}

impl std::fmt::Debug for YYStack {
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
  pub const YYACCEPT: i32 = 0;

  /**
   * Returned by a Bison action in order to stop the parsing process and
   * return failure (<tt>false</tt>).
   */
  pub const YYABORT: i32 = 1;

][

  /**
   * Returned by a Bison action in order to start error recovery without
   * printing an error message.
   */
  pub const YYERROR: i32 = 2;

  /**
   * Internal return codes that are not supported for user semantic
   * actions.
   */
  pub const YYERRLAB: i32 = 3;
  pub const YYNEWSTATE: i32 = 4;
  pub const YYDEFAULT: i32 = 5;
  pub const YYREDUCE: i32 = 6;
  pub const YYERRLAB1: i32 = 7;
  #@{allow(dead_code)@}
  pub const YYRETURN: i32 = 8;
][

][
  /**
   * Whether error recovery is being done.  In this state, the parser
   * reads token until it reaches a known state, and then restarts normal
   * operation.
   */
  #@{allow(dead_code)@}
  pub fn recovering(&self) -> bool {
      self.yyerrstatus_ == 0
  }

  /** Compute post-reduction state.
   * @@param yystate   the current state
   * @@param yysym     the nonterminal to push on the stack
   */
  fn yy_lr_goto_state(&self, yystate: i32, yysym: i32) -> i32 {
      let _idx: usize = (yysym - Self::YYNTOKENS_).try_into().unwrap();
      let yyr: i32 = Self::yypgoto_[_idx] as i32 + yystate;
      if 0 <= yyr && yyr <= Self::YYLAST_ {
        let yyr_usize: usize = yyr.try_into().unwrap();
        if i32::from(Self::yycheck_[yyr_usize]) == yystate {
          let result: i32 =  Self::yytable_[yyr_usize].into();
          return result
        }
      }
      Self::yydefgoto_[_idx].into()
  }

  fn yyaction(&mut self, yyn: i32, yystack: &mut YYStack, yylen: &mut i32) -> i32 {][
    /* If YYLEN is nonzero, implement the default value of the action:
       '$$ = $1'.  Otherwise, use the top of the stack.

       Otherwise, the following line sets YYVAL to garbage.
       This behavior is undocumented and Bison
       users should not rely upon it.  */
    let mut yyval: ]b4_yystype[ = if 0 < *yylen { yystack.value_at(*yylen - 1).clone() } else { yystack.value_at(0).clone() };
    ]b4_locations_if([[
    let yyloc: ]b4_location_type[ = make_yylloc(&yystack, *yylen);]])[]b4_parse_trace_if([[

    self.yy_reduce_print(yyn, yystack);]])[

    match yyn {
        ]b4_user_actions[
        _ => {}
    }]b4_parse_trace_if([[

    let yyn_usize: usize = yyn.try_into().unwrap();
    self.yy_symbol_print("-> $$ =", SymbolKind::get(Self::yyr1_[yyn_usize].try_into().unwrap()), &yyval]b4_locations_if([, &yyloc])[);]])[

    yystack.pop_n(*yylen);
    *yylen = 0;
    /* Shift the result of the reduction.  */
    let yystate = self.yy_lr_goto_state(yystack.state_at(0).clone() as i32, Self::yyr1_[yyn_usize].into());
    yystack.push(yystate.try_into().unwrap(), &yyval]b4_locations_if([, &yyloc])[);
    return Self::YYNEWSTATE;
  }

]b4_parse_trace_if([[
  /*--------------------------------.
  | Print this symbol on YYOUTPUT.  |
  `--------------------------------*/

  fn yy_symbol_print(&self, s: &str, yykind: &SymbolKind,
                             yyvalue: &]b4_yystype[]b4_locations_if([, yylocation: &]b4_location_type[])[) {
      if 0 < self.yydebug {
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
    yystack.push (yystate, &yylval]b4_locations_if([, &yylloc])[);
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
        if 0 < self.yydebug { eprintln!("{:#?}", yystack) }]])[

        /* Accept?  */
        if i32::from(yystate) == Self::YYFINAL_ {
          return true;
        }

        /* Take a decision.  First try without lookahead.  */
        let yystate_usize: usize = yystate.try_into().unwrap();
        yyn = Self::yypact_[yystate_usize].into();
        if yy_pact_value_is_default(yyn) {
          label = Self::YYDEFAULT;
          continue;
        }

        /* Read a lookahead token.  */
        if yychar == Self::YYEMPTY_ {
]b4_parse_trace_if([[
            self.yycdebug("Reading a token");]])[
            let yylex: Token = self.yylexer.yylex();
            yychar = yylex.0;
            yylval = ]b4_yystype[::from_token(yylex.clone());]b4_locations_if([[
            yylloc = yylex.2;]])[
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
            // let yyn_usize: usize = yyn.try_into().unwrap();
            if yyn < 0 || Self::YYLAST_ < yyn || i32::from(Self::yycheck_[usize::try_from(yyn).unwrap()]) != yytoken.code() {
              label = Self::YYDEFAULT;
            }

            /* <= 0 means reduce or error.  */
            else {
              yyn = Self::yytable_[usize::try_from(yyn).unwrap()].into();
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
                yystack.push (yystate, &yylval]b4_locations_if([, &yylloc])[);
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
        let yystate_usize: usize = yystate.try_into().unwrap();
        yyn = Self::yydefact_[yystate_usize].into();
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
        let yyn_usize: usize = yyn.try_into().unwrap();
        yylen = Self::yyr2_[yyn_usize].into();
        label = self.yyaction(yyn, &mut yystack, &mut yylen);
        yystate = *yystack.state_at(0);
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
      Self::YYERROR => {]b4_locations_if([[
        yyerrloc = yystack.location_at(yylen - 1).clone();]])[
        /* Do not reclaim the symbols of the rule which action triggered
           this YYERROR.  */
        yystack.pop_n(yylen);
        yylen = 0;
        yystate = yystack.state_at(0).clone();
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
            let yystate_usize: usize = yystate.try_into().unwrap();
            yyn = Self::yypact_[yystate_usize].into();
            if !yy_pact_value_is_default(yyn) {
                yyn += SymbolKind { value: SymbolKind::S_YYerror }.code();
                let yyn_usize: usize = yyn.try_into().unwrap();
                if 0 <= yyn && yyn <= Self::YYLAST_ && i32::from(Self::yycheck_[yyn_usize]) == SymbolKind::S_YYerror
                  {
                    yyn = Self::yytable_[yyn_usize].into();
                    if 0 < yyn {
                      break;
                    }
                  }
            }

            /* Pop the current state because it cannot handle the
             * error token.  */
            if yystack.is_empty() {
              return false;
            }

]b4_locations_if([[
            yyerrloc = yystack.location_at(0).clone();]])[
            yystack.pop();
            yystate = yystack.state_at(0).clone();]b4_parse_trace_if([[
            if 0 < self.yydebug {
              eprintln!("{:#?}", yystack);]])[
            }
          }

        if label == Self::YYABORT {
          /* Leave the switch.  */
          continue;
        }

]b4_locations_if([[
        /* Muck with the stack to setup for yylloc.  */
        yystack.push(0, &]b4_yystype[::None, &yylloc);
        yystack.push(0, &]b4_yystype[::None, &yyerrloc);
        yyloc = make_yylloc(&yystack, 2);
        yystack.pop_n(2);]])[

        /* Shift the error token.  */]b4_parse_trace_if([[
        let yyn_usize: usize = yyn.try_into().unwrap();
        self.yy_symbol_print("Shifting", SymbolKind::get(Self::yystos_[yyn_usize].try_into().unwrap()),
                      &yylval]b4_locations_if([, &yyloc])[);]])[

        yystate = yyn;
        yystack.push (yyn, &yylval]b4_locations_if([, &yyloc])[);
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
struct Context {
    yystack: YYStack,
    yytoken: SymbolKind,
    loc: ]b4_location_type[
}

impl Context {
    pub fn new(stack: YYStack, token: SymbolKind, loc: ]b4_location_type[) -> Self {
        Self { yystack: stack, yytoken: token, loc }
    }

    #@{allow(dead_code)@}
    pub fn token(&self) -> &SymbolKind {
        &self.yytoken
    }

    #@{allow(dead_code)@}
    pub fn location(&self) -> &]b4_location_type[ {
        &self.loc
    }
}

][

impl ]b4_parser_struct[ {
  /**
   * Build and emit a "syntax error" message in a user-defined way.
   *
   * @@param ctx  The context of the error.
   */
  fn report_syntax_error(&self, yyctx: &Context) {
      self.yylexer.report_syntax_error(yyctx);
  }

}

/**
  * Whether the given <code>yypact_</code> value indicates a defaulted state.
  * @@param yyvalue   the value to check
  */
fn yy_pact_value_is_default(yyvalue: i32) -> bool {
  return yyvalue == YYPACT_NINF_.into();
}

/**
  * Whether the given <code>yytable_</code>
  * value indicates a syntax error.
  * @@param yyvalue the value to check
  */
fn yy_table_value_is_error(yyvalue: i32) -> bool {
  return yyvalue == YYTABLE_NINF_.into();
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
    if self.yydebug == 0 {
      return;
    }

    let yyrule_usize: usize = yyrule.try_into().unwrap();
    let yylno = Self::yyrline_[yyrule_usize];
    let yynrhs = Self::yyr2_[yyrule_usize];
    /* Print the symbols being reduced, and their result.  */
    self.yycdebug(&format!("Reducing stack by rule {} (line {}):", yyrule - 1,
              yylno));

    /* The symbols being reduced.  */
    for yyi in 0..yynrhs {
      let state: usize = yystack.state_at((yynrhs - (yyi + 1)).into()).clone().try_into().unwrap();
      self.yy_symbol_print(&format!("   ${} =", yyi + 1),
                    SymbolKind::get(Self::yystos_[state].try_into().unwrap()),
                    yystack.value_at(((yynrhs) - (yyi + 1)).into())]b4_locations_if([,
                    yystack.location_at(((yynrhs) - (yyi + 1)).into())])[);
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
      return ]b4_symbol(0, kind)[;
    } else if t <= code_max {
      let t_usize: usize = t.try_into().unwrap();
      return SymbolKind::get(Self::yytranslate_table_[t_usize].try_into().unwrap()).clone();
    } else {
      return ]b4_symbol(2, kind)[;
    }
  }
  ]b4_integral_parser_table_define([translate_table], [b4_translate])[
]])[

const YYLAST_: i32 = ]b4_last[;
const YYEMPTY_: i32 = -2;
const YYFINAL_: i32 = ]b4_final_state_number[;
const YYNTOKENS_: i32 = ]b4_tokens_number[;

]b4_percent_code_get[
}

impl ]b4_parser_struct[ {
    pub fn build() -> Self {
        Self {
          yy_error_verbose: true,
          yynerrs: 0,
          yydebug: 0,
          yyerrstatus_: 0,
          ..Self::default()
        }
    }
}

]b4_percent_code_get([[epilogue]])[]dnl
b4_epilogue[]dnl
b4_output_end
