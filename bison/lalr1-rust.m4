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
    let mut yytoken = &DYMMY_SYMBOL_KIND;

    /* State.  */
    let mut yyn: i32 = 0;
    let mut yylen: usize = 0;
    let mut yystate: i32 = 0;
    let mut yystack = YYStack::new();
    let mut label: i32 = Self::YYNEWSTATE;

    /* The location where the error started.  */
    let mut yyerrloc: YYLoc = YYLoc { begin: 0, end: 0 };

    /* Location. */
    let mut yylloc: YYLoc = YYLoc { begin: 0, end: 0 };

    /* Semantic value of the lookahead.  */
    let mut yylval: YYValue = YYValue::Uninitialized;
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

/// A Bison parser, automatically generated from ]m4_bpatsubst(b4_file_name, [^"\(.*\)"$], [\1])[.
#@{derive(Debug)@}
pub struct ]b4_parser_struct[]b4_parser_generic[ {
    /// Lexer that is used to get tokens
    pub yylexer: Lexer,
    // true if verbose error messages are enabled.
    #@{allow(dead_code)@}
    yy_error_verbose: bool,
    // number of errors so far
    yynerrs: i32,

    yyerrstatus_: i32,

    ]b4_percent_code_get([[parser_fields]])[
}

#[inline]
fn i32_to_usize(v: i32) -> usize {
    v as usize
}

/// Maps token ID into human-readable name
pub fn token_name(id: i32) -> &'static str { /* ' */
    let first_token = Lexer::YYerror;
    if id > first_token + 1 {
        let pos: usize = (id - first_token + 1)
            .try_into()
            .expect("failed to cast token id into usize, is it negative?");
        Lexer::TOKEN_NAMES@{pos@}
    } else if id == 0 {
        "EOF"
    } else {
        panic!("token_name fails, {} (first token = {})", id, first_token)
    }
}

/// Local alias
type YYLoc = Loc;

impl]b4_parser_generic[ ]b4_parser_struct[]b4_parser_generic[ {]
b4_identification[]
[}]

[
fn make_yylloc(rhs: &YYStack, n: usize) -> YYLoc {
    if 0 < n {
        YYLoc {
            begin: rhs.location_at(n - 1).begin,
            end: rhs.location_at(0).end
        }
    } else {
        YYLoc {
            begin: rhs.location_at(0).end,
            end: rhs.location_at(0).end
        }
    }
}

]b4_declare_symbol_enum[

const DYMMY_SYMBOL_KIND: SymbolKind = SymbolKind { value: 0 };

impl Lexer {
    ]b4_token_enums[

    // Deprecated, use ]b4_symbol(0, id)[ instead.
    #@{allow(dead_code)@}
    const EOF: i32 = Self::]b4_symbol(0, id)[;

    // Token values
    #@{allow(dead_code)@}
    pub(crate) const TOKEN_NAMES: &'static @{&'static str@} = &]b4_token_values[;
}
]

[impl]b4_parser_generic[ ]b4_parser_struct[]b4_parser_generic[ {

    fn yycdebug(&self, s: &str) {
        if ]b4_parser_check_debug[ {
            eprintln!("{}", s);
        }
    }][

}

/// Local alias
type YYValue = ]b4_yystype[;

#[derive(Debug)]
struct YYStackItem {
    state: i32,
    value: YYValue,
    loc: YYLoc,
}

#[derive(Debug)]
pub struct YYStack {
    stack: Vec<YYStackItem>,
}

impl YYStack {
    pub(crate) fn new() -> Self {
        Self {
          stack: Vec::with_capacity(20),
        }
    }

    pub(crate) fn push(&mut self, state: i32, value: YYValue, loc: YYLoc) {
        self.stack.push(YYStackItem { state, value, loc });
    }

    pub(crate) fn pop(&mut self) {
        self.stack.pop();
    }

    pub(crate) fn pop_n(&mut self, num: usize) {
        let len = self.stack.len() - num;
        self.stack.truncate(len);
    }

    pub(crate) fn state_at(&self, i: usize) -> i32 {
        self.stack[self.len() - 1 - i].state
    }

    pub(crate) fn location_at(&self, i: usize) -> &YYLoc {
        &self.stack[self.len() - 1 - i].loc
    }

    pub(crate) fn borrow_value_at(&self, i: usize) -> &YYValue {
        &self.stack[self.len() - 1 - i].value
    }

    pub(crate) fn owned_value_at(&mut self, i: usize) -> YYValue {
        let len = self.len();
        std::mem::take(&mut self.stack[len - 1 - i].value)
    }

    pub(crate) fn len(&self) -> usize {
      self.stack.len()
    }
}

impl std::fmt::Display for YYStack {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let states = self.stack.iter().map(|e| e.state.to_string()).collect::<Vec<String>>().join(" ");
        let values = self.stack.iter().map(|e| format!("{:?}", e.value)).collect::<Vec<String>>().join(" ");
        f.write_fmt(format_args!("Stack now states = {} / values = {:?} ", states, values))
    }
}

impl]b4_parser_generic[ ]b4_parser_struct[]b4_parser_generic[ {
  /// Returned by a Bison action in order to stop the parsing process and
  /// return success (true).
  pub(crate) const YYACCEPT: i32 = 0;

  /// Returned by a Bison action in order to stop the parsing process and
  /// return failure (false).
  pub(crate) const YYABORT: i32 = 1;

  /// Returned by a Bison action in order to start error recovery without
  /// printing an error message.
  pub(crate) const YYERROR: i32 = 2;

  /// Internal return codes that are not supported for user semantic
  /// actions.
  pub(crate) const YYERRLAB: i32 = 3;
  pub(crate) const YYNEWSTATE: i32 = 4;
  pub(crate) const YYDEFAULT: i32 = 5;
  pub(crate) const YYREDUCE: i32 = 6;
  pub(crate) const YYERRLAB1: i32 = 7;
  #@{allow(dead_code)@}
  pub(crate) const YYRETURN: i32 = 8;

  /// Whether error recovery is being done.  In this state, the parser
  /// reads token until it reaches a known state, and then restarts normal
  /// operation.
  #@{allow(dead_code)@}
  pub(crate) fn recovering(&self) -> bool {
      self.yyerrstatus_ == 0
  }

    // Compute post-reduction state.
    // yystate:   the current state
    // yysym:     the nonterminal to push on the stack
    fn yy_lr_goto_state(&self, yystate: i32, yysym: i32) -> i32 {
        let idx = i32_to_usize(yysym - Self::YYNTOKENS_);
        let yyr = Self::yypgoto_[idx] + yystate;
        if (0..=Self::YYLAST_).contains(&yyr) {
            let yyr = i32_to_usize(yyr);
            if Self::yycheck_[yyr] == yystate {
                return Self::yytable_[yyr];
            }
        }
        Self::yydefgoto_[idx]
    }

    fn yyaction(&mut self, yyn: i32, yystack: &mut YYStack, yylen: &mut usize) -> Result<i32, ()> {
        // If YYLEN is nonzero, implement the default value of the action:
        // '$$ = $1'.  Otherwise, use the top of the stack.
        //
        // Otherwise, the following line sets YYVAL to garbage.
        // This behavior is undocumented and Bison
        // users should not rely upon it.
        #@{allow(unused_assignments)@}
        let mut yyval: YYValue = YYValue::Uninitialized;
        let yyloc: YYLoc = make_yylloc(yystack, *yylen);

        self.yy_reduce_print(yyn, yystack);

        match yyn {
            ]b4_user_actions[
            _ => {}
        }

        if let YYValue::Uninitialized = yyval {
            panic!("yyval is Uninitialized in rule at line {}", Self::yyrline_[i32_to_usize(yyn)]);
        }

        self.yy_symbol_print("-> $$ =", SymbolKind::get(Self::yyr1_[i32_to_usize(yyn)]), &yyval, &yyloc);

        yystack.pop_n(*yylen);
        *yylen = 0;
        /* Shift the result of the reduction.  */
        let yystate = self.yy_lr_goto_state(yystack.state_at(0), Self::yyr1_[i32_to_usize(yyn)]);
        yystack.push(yystate, yyval, yyloc);
        Ok(Self::YYNEWSTATE)
    }

    // Print this symbol on YYOUTPUT.
    fn yy_symbol_print(&self, s: &str, yykind: &SymbolKind, yyvalue: &YYValue, yylocation: &YYLoc) {
        if ]b4_parser_check_debug[ {
            self.yycdebug(
                &format!("{}{} {:?} ( {:?}: {:?} )", // " fix highlighting
                s,
                if yykind.code() < Self::YYNTOKENS_ { " token " } else { " nterm " },
                yykind.name(),
                yylocation,
                yyvalue
                )
            )
        }
    }

    /// Parses given input. Returns true if the parsing was successful.
    pub fn parse(&mut self) -> bool {
        /* @@$.  */
        let mut yyloc: YYLoc;
        ]b4_define_state[
        self.yycdebug("Starting parse");
        self.yyerrstatus_ = 0;
        self.yynerrs = 0;

        /* Initialize the stack.  */
        yystack.push(yystate, yylval.clone(), yylloc);

        loop {
            match label {
                // New state.  Unlike in the C/C++ skeletons, the state is already
                // pushed when we come here.

                Self::YYNEWSTATE => {
                    if ]b4_parser_check_debug[ {
                        self.yycdebug(&format!("Entering state {}", yystate));
                        eprintln!("{}", yystack);
                    }

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
                        self.yycdebug("Reading a token");
                        let token = self.next_token();
                        yychar = token.token_type;
                        yylloc = token.loc;
                        yylval = YYValue::from_token(token);
                    }

                    /* Convert token to internal form.  */
                    yytoken = Self::yytranslate_(yychar);
                    self.yy_symbol_print("Next token is", yytoken, &yylval, &yylloc);

                    if yytoken == SymbolKind::get(1) {
                        // The scanner already issued an error message, process directly
                        // to error recovery.  But do not keep the error token as
                        // lookahead, it is too special and may lead us to an endless
                        // loop in error recovery. */
                        yychar = Lexer::]b4_symbol(2, id)[;
                        yytoken = SymbolKind::get(2);
                        yyerrloc = yylloc;
                        label = Self::YYERRLAB1;
                    } else {
                        // If the proper action on seeing token YYTOKEN is to reduce or to
                        // detect an error, take that action.
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
                                /* Shift the lookahead token.  */
                                self.yy_symbol_print("Shifting", yytoken, &yylval, &yylloc);

                                /* Discard the token being shifted.  */
                                yychar = Self::YYEMPTY_;

                                /* Count tokens shifted since error; after three, turn off error status.  */
                                if self.yyerrstatus_ > 0 {
                                    self.yyerrstatus_ -= 1;
                                }

                                yystate = yyn;
                                yystack.push(yystate, std::mem::take(&mut yylval), std::mem::take(&mut yylloc));
                                label = Self::YYNEWSTATE;
                            }
                        }
                    }
                    continue;
                }, // YYNEWSTATE

                // yydefault -- do the default action for the current state.
                Self::YYDEFAULT => {
                    yyn = Self::yydefact_[i32_to_usize(yystate)];
                    if yyn == 0 {
                        label = Self::YYERRLAB;
                    } else {
                        label = Self::YYREDUCE;
                    }
                    continue;
                } // YYDEFAULT

                // yyreduce -- Do a reduction.
                Self::YYREDUCE => {
                    yylen = i32_to_usize(Self::yyr2_[i32_to_usize(yyn)]);
                    label = match self.yyaction(yyn, &mut yystack, &mut yylen) {
                        Ok(label) => label,
                        Err(_) => Self::YYERROR
                    };
                    yystate = yystack.state_at(0);
                    continue;
                }, // YYREDUCE

                // yyerrlab -- here on detecting error
                Self::YYERRLAB => {
                    /* If not already recovering from an error, report this error.  */
                    if self.yyerrstatus_ == 0 {
                        self.yynerrs += 1;
                        if yychar == Self::YYEMPTY_ {
                            yytoken = &DYMMY_SYMBOL_KIND;
                        }
                        self.report_syntax_error(&yystack, yytoken, yylloc);
                    }
                    yyerrloc = yylloc;
                    if self.yyerrstatus_ == 3 {
                        // If just tried and failed to reuse lookahead token after an error, discard it.

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

                    // Else will try to reuse lookahead token after shifting the error token.
                    label = Self::YYERRLAB1;
                    continue;
                }, // YYERRLAB

                // errorlab -- error raised explicitly by YYERROR.
                Self::YYERROR => {
                    /* Do not reclaim the symbols of the rule which action triggered
                    this YYERROR.  */
                    yystack.pop_n(yylen);
                    yylen = 0;
                    yystate = yystack.state_at(0);
                    label = Self::YYERRLAB1;
                    continue;
                }, // YYERROR

                // yyerrlab1 -- common code for both syntax error and YYERROR.
                Self::YYERRLAB1 => {
                    self.yyerrstatus_ = 3;       /* Each real token shifted decrements this.  */

                    // Pop stack until we find a state that shifts the error token.
                    loop {
                        yyn = Self::yypact_[i32_to_usize(yystate)];
                        if !yy_pact_value_is_default(yyn) {
                            yyn += SymbolKind { value: SymbolKind::S_YYerror }.code();
                            if (0..=Self::YYLAST_).contains(&yyn) {
                                let yyn_usize = i32_to_usize(yyn);
                                if Self::yycheck_[yyn_usize] == SymbolKind::S_YYerror {
                                    yyn = Self::yytable_[yyn_usize];
                                    if 0 < yyn {
                                        break;
                                    }
                                }
                            }
                        }

                        // Pop the current state because it cannot handle the error token.
                        if yystack.len() == 1 {
                            return false;
                        }

                        yyerrloc = *yystack.location_at(0);
                        yystack.pop();
                        yystate = yystack.state_at(0);
                        if ]b4_parser_check_debug[ {
                            eprintln!("{}", yystack);
                        }
                    }

                    if label == Self::YYABORT {
                        /* Leave the switch.  */
                        continue;
                    }

                    /* Muck with the stack to setup for yylloc.  */
                    yystack.push(0, YYValue::Uninitialized, yylloc);
                    yystack.push(0, YYValue::Uninitialized, yyerrloc);
                    yyloc = make_yylloc(&yystack, 2);
                    yystack.pop_n(2);

                    /* Shift the error token.  */
                    self.yy_symbol_print("Shifting", SymbolKind::get(Self::yystos_[i32_to_usize(yyn)]), &yylval, &yyloc);

                    yystate = yyn;
                    yystack.push(yyn, yylval.clone(), yyloc);
                    label = Self::YYNEWSTATE;
                    continue;
                }, // YYERRLAB1

                // Accept
                Self::YYACCEPT => {
                    return true;
                }

                // Abort.
                Self::YYABORT => {
                    return false;
                },

                _ => {
                    panic!("internal bison error: unknown label {}", label);
                }
            }
        }
    }
}

// Whether the given `yypact_` value indicates a defaulted state.
fn yy_pact_value_is_default(yyvalue: i32) -> bool {
    yyvalue == YYPACT_NINF_
}

// Whether the given `yytable_`
// value indicates a syntax error.
// yyvalue: the value to check
fn yy_table_value_is_error(yyvalue: i32) -> bool {
    yyvalue == YYTABLE_NINF_
}

const YYPACT_NINF_: ]b4_int_type_for([b4_pact])[ = ]b4_pact_ninf[;
const YYTABLE_NINF_: ]b4_int_type_for([b4_table])[ = ]b4_table_ninf[;

impl]b4_parser_generic[ ]b4_parser_struct[]b4_parser_generic[ {

]b4_parser_tables_define[

]b4_integral_parser_table_define([rline], [b4_rline],
  [[YYRLINE[YYN] -- Source line where rule number YYN was defined.]])[

][
  // Report on the debug stream that the rule yyrule is going to be reduced.
  fn yy_reduce_print(&self, yyrule: i32, yystack: &YYStack) {
        if !(]b4_parser_check_debug[) {
            return;
        }

        let yylno = Self::yyrline_[i32_to_usize(yyrule)];
        let yynrhs = Self::yyr2_[i32_to_usize(yyrule)];
        // Print the symbols being reduced, and their result.
        self.yycdebug(&format!("Reducing stack by rule {} (line {}):", /* " fix */ yyrule - 1, yylno));

        // The symbols being reduced.
        for yyi in 0..yynrhs {
            let state: usize = i32_to_usize(yystack.state_at(i32_to_usize(yynrhs - (yyi + 1))));
            self.yy_symbol_print(
                &format!("   ${} =", yyi + 1),
                SymbolKind::get(Self::yystos_[state]),
                yystack.borrow_value_at(i32_to_usize(yynrhs - (yyi + 1))),
                yystack.location_at(i32_to_usize(yynrhs - (yyi + 1)))
            );
        }
  }][

  /* YYTRANSLATE_(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
     as returned by yylex, with out-of-bounds checking.  */
  fn yytranslate_(t: i32) -> &'static SymbolKind
]b4_api_token_raw_if(dnl
[[  {
    return SymbolKind::get(t);
  }
]],
[[  {
        // Last valid token kind.
        let code_max: i32 = ]b4_code_max[;
        if t <= 0 {
            SymbolKind::get(0)
        } else if t <= code_max {
            let t = i32_to_usize(t);
            SymbolKind::get(Self::yytranslate_table_[t])
        } else {
            SymbolKind::get(2)
        }
  }
  ]b4_integral_parser_table_define([translate_table], [b4_translate])[
]])[

const YYLAST_: i32 = ]b4_last[;
const YYEMPTY_: i32 = -2;
const YYFINAL_: i32 = ]b4_final_state_number[;
const YYNTOKENS_: i32 = ]b4_tokens_number[;
]b4_locations_if([])[
]b4_parse_trace_if([])[
}

]b4_percent_code_get[

]b4_percent_code_get([[epilogue]])[]dnl
b4_epilogue[]dnl
b4_output_end
