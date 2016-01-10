describe "Xù grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-mscgen")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.xu")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.xu"

  describe "A simple, complete (but invalid) Xù script", ->
    lines = null

    beforeEach ->
      lines = grammar.tokenizeLines """
        # Smoke test
        msc {
        /* options */
          wordwraparcs=on, watermark="nice watermark";

        # some entities
          "a" [label=/* comment in a weird place */"Entity A /* comment in a string*/ hscale"],
          label [label=abox];
        =
        // arcs
          "a" =>> label [label="do something"];
          label >> "a" [label="done!", linecolor="gray"];

          "a" => "a" [label="happiness & stuff"],
          label note label [label="Not sure what perspired there.\\n(perspired -> I mean happened)"];
          "a" abox label [label="angled box here"];
          a alt label [label="all is good"] {
            label >> a [label="Oh yeah!"];
            ---;
            label >> a [label="Nope", textcolour="red"];
          };
        }
        """

    it "recognizes comments", ->
      expectLegalHashComment(lines[5])
      expectLegalSlashComment(lines[9])

    it "recognizes the start token", ->
      expect(lines[1][0]).toEqual value: "msc ", scopes: [
        "source.xu",
        "storage.type.xu"
      ]
      expect(lines[1][1]).toEqual value: "{", scopes: [
        "source.xu",
        "storage.type.xu",
        "punctuation.definition.program.end.xu"
       ]

    it "recognizes option keywords", ->
      expect(lines[3][1]).toEqual value: "wordwraparcs", scopes: [
        "source.xu",
        "storage.modifier.xu",
      ]

    it "recognizes option assignments", ->
      expect(lines[3][2]).toEqual value: "=", scopes: [
              "source.xu",
              "storage.type.xu",
            ]

    it "recognizes option constants", ->
      expect(lines[3][3]).toEqual value: "on", scopes: [
              "source.xu",
              "constant.language.xu",
            ]

    it "recognizes xu specific option keywords", ->
      expect(lines[3][6]).toEqual value: "watermark", scopes: [
        "source.xu",
        "storage.modifier.xu",
      ]

    describe "outside attribute blocks", ->
      it "classifies attribute-like tokens as variables", ->
        expect(lines[7][1]).toEqual value: "label", scopes: [
          "source.xu",
          "variable.identifier.xu"
        ]
      it "classifies equals signs as illegal", ->
        expect(lines[8][0]).toEqual value: "=", scopes: [
          "source.xu",
          "invalid.illegal.xu"
        ]
      it "classifies identifier-like tokens (arc type here) as arc type", ->
        expect(lines[15][5]).toEqual value: "abox", scopes: [
          "source.xu",
          "storage.type.xu"
        ]
      it "classifies xu specific arc types as arc type", ->
        expect(lines[16][3]).toEqual value: "alt", scopes: [
          "source.xu",
          "storage.type.xu"
        ]
    describe "within attribute blocks", ->
      it "classifies attribute-like tokens as attributes", ->
        expect(lines[7][4]).toEqual value: "label", scopes: [
          "source.xu",
          "keyword.operator.xu",
          "keyword.attribute.xu"
        ]
      it "classifies equal signs as operator", ->
        expect(lines[7][5]).toEqual value: "=", scopes: [
          "source.xu",
          "keyword.operator.xu",
          "storage.type.xu"
        ]
      it "classifies identifier-like tokens (even when it's an arc type token) as strings", ->
        expect(lines[7][6]).toEqual value: "abox", scopes: [
          "source.xu",
          "keyword.operator.xu",
          "string.identifier.as.attribute.value.xu"
        ]

      describe "within strings", ->
        it "leaves comments and keywords as is", ->
          expect(lines[6][12]).toEqual value: "Entity A /* comment in a string*/ hscale", scopes: [
            "source.xu",
            "keyword.operator.xu",
            "string.quoted.double.xu"
          ]

        it "recognizes escaped characters", ->
          expect(lines[14][12]).toEqual value: "\\n", scopes: [
            "source.xu",
            "keyword.operator.xu",
            "string.quoted.double.xu",
            "constant.character.escape.xu"
          ]

  describe "Outside msc {} scope", ->
    it "treats single line hashmark comments as comments", ->
      {tokens} = grammar.tokenizeLine "# legal"
      expectLegalHashComment (tokens)

    it "treats single line double slash comments as comments", ->
      {tokens} = grammar.tokenizeLine("// also legal")
      expectLegalSlashComment (tokens)

    it "treats multi line comments as comments", ->
      lines = grammar.tokenizeLines """
        /* multi line comments
           outside msc blocks are super legal as wel
         */"""
      expect(lines[0][0]).toEqual value: "/*", scopes: [
        "source.xu",
        "comment.block.xu",
        "punctuation.definition.comment.xu"
      ]
      expect(lines[0][1]).toEqual value: " multi line comments", scopes: [
        "source.xu",
        "comment.block.xu",
      ]
      expect(lines[1][0]).toEqual value: "   outside msc blocks are super legal as wel", scopes: [
        "source.xu",
        "comment.block.xu",
      ]
      expect(lines[2][0]).toEqual value: " ", scopes: [
        "source.xu",
        "comment.block.xu",
      ]
      expect(lines[2][1]).toEqual value: "*/", scopes: [
        "source.xu",
        "comment.block.xu",
        "punctuation.definition.comment.xu"
      ]

    it "leaves spaces alone", ->
      {tokens} = grammar.tokenizeLine("            ")
      expect(tokens[0]).toEqual value: "            ", scopes: [
        "source.xu"
      ]

    it "declares everything else illegal", ->
      {tokens} = grammar.tokenizeLine("= not legal")
      expect(tokens[0]).toEqual value: "=", scopes: [
        "source.xu",
        "invalid.illegal.xu"
      ]

    it "declares stuff illegal that would be legal within msc {} scope", ->
      {tokens} = grammar.tokenizeLine("illegal box illegal;")
      expect(tokens[0]).toEqual value: "i", scopes: [
        "source.xu",
        "invalid.illegal.xu"
      ]

expectLegalHashComment = (tokens) ->
  expect(tokens[0]).toEqual value: "#", scopes: [
    "source.xu",
    "comment.line.number-sign.xu",
    "punctuation.definition.comment.xu"
  ]
  expect(tokens[1].scopes).toEqual [
    "source.xu",
    "comment.line.number-sign.xu",
  ]

expectLegalSlashComment = (tokens) ->
  expect(tokens[0]).toEqual value: "//", scopes: [
    "source.xu",
    "comment.line.double-slash.xu",
    "punctuation.definition.comment.xu"
  ]
  expect(tokens[1].scopes).toEqual [
    "source.xu",
    "comment.line.double-slash.xu",
  ]
