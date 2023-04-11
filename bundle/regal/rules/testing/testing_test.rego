package regal.rules.testing_test

import future.keywords.if

import data.regal.ast
import data.regal.config
import data.regal.rules.testing

test_fail_test_outside_test_package if {
	report(`test_foo { false }`) == {{
		"category": "testing",
		"description": "Test outside of test package",
		"related_resources": [{
			"description": "documentation",
			"ref": "https://docs.styra.com/regal/rules/test-outside-test-package",
		}],
		"title": "test-outside-test-package",
		"location": {"col": 1, "file": "policy.rego", "row": 8},
	}}
}

test_success_test_inside_test_package if {
	ast := rego.parse_module("foo_test.rego", `
	package foo_test

	test_foo { false }
	`)
	result := testing.report with input as ast
	result == set()
}

test_fail_identically_named_tests if {
	ast := rego.parse_module("foo_test.rego", `
	package foo_test

	test_foo { false }
	test_foo { true }
	`)
	result := testing.report with input as ast
	result == {{
		"category": "testing",
		"description": "Multiple tests with same name",
		"related_resources": [{
			"description": "documentation",
			"ref": "https://docs.styra.com/regal/rules/identically-named-tests",
		}],
		"title": "identically-named-tests",
	}}
}

test_success_differently_named_tests if {
	ast := rego.parse_module("foo_test.rego", `
	package foo_test

	test_foo { false }
	test_bar { true }
	test_baz { 1 == 1 }
	`)
	result := testing.report with input as ast
	result == set()
}

test_fail_todo_test if {
	ast := rego.parse_module("foo_test.rego", `
	package foo_test

	todo_test_foo { false }

	test_bar { true }
	`)
	result := testing.report with input as ast
	result == {{
		"category": "testing",
		"description": "TODO test encountered",
		"related_resources": [{
			"description": "documentation",
			"ref": "https://docs.styra.com/regal/rules/todo-test",
		}],
		"title": "todo-test",
	}}
}

report(snippet) := report if {
	# regal ignore:input-or-data-reference
	report := testing.report with input as ast.with_future_keywords(snippet) with config.for_rule as {"enabled": true}
}
