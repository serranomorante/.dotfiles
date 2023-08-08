---@diagnostic disable: undefined-global
return {
	s(
		"ra_form_print",
		fmt(
			[[
	  <FormDataConsumer>
	    {{({{ {} }}) => (
          <pre>{{JSON.stringify({}, null, 2)}}</pre>
        )
      }}
	  </FormDataConsumer>
	]],
			{ i(1, "formData"), rep(1) }
		)
	),
}
