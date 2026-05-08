-- Sample Busted spec file demonstrating setup/teardown and pending tests

local string_utils = {}

function string_utils.trim(s)
  return s:match("^%s*(.-)%s*$")
end

function string_utils.split(s, sep)
  sep = sep or " "
  local result = {}
  for token in s:gmatch("([^" .. sep .. "]+)") do
    table.insert(result, token)
  end
  return result
end

function string_utils.starts_with(s, prefix)
  return s:sub(1, #prefix) == prefix
end

describe("string_utils", function()
  local sample

  setup(function()
    -- Runs once before all tests in this describe block
    sample = "  hello world  "
  end)

  teardown(function()
    -- Runs once after all tests in this describe block
    sample = nil
  end)

  describe("trim", function()
    it("removes leading and trailing whitespace", function()
      assert.are.equal("hello world", string_utils.trim(sample))
    end)

    it("returns empty string for whitespace-only input", function()
      assert.are.equal("", string_utils.trim("   "))
    end)
  end)

  describe("split", function()
    it("splits on the given separator", function()
      local parts = string_utils.split("a,b,c", ",")
      assert.are.same({"a", "b", "c"}, parts)
    end)

    it("defaults to space as separator", function()
      local parts = string_utils.split("hello world")
      assert.are.same({"hello", "world"}, parts)
    end)
  end)

  describe("starts_with", function()
    it("returns true when prefix matches", function()
      assert.is_true(string_utils.starts_with("hello world", "hello"))
    end)

    it("returns false when prefix does not match", function()
      assert.is_false(string_utils.starts_with("hello world", "world"))
    end)

    pending("supports unicode prefixes (not implemented yet)")
  end)
end)
