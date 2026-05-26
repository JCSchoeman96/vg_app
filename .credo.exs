%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/"],
        excluded: [~r"/_build/", ~r"/deps/"]
      },
      checks: [
        {Credo.Check.Design.AliasUsage, false},
        {Credo.Check.Design.TagTODO, false},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Refactor.Nesting, false}
      ]
    }
  ]
}
