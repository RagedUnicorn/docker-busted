-- Sample Busted spec file demonstrating common assertions
-- Run with: docker run -v $(pwd):/workspace ragedunicorn/busted:latest spec/calculator_spec.lua

local calculator = {}

function calculator.add(a, b)
  return a + b
end

function calculator.subtract(a, b)
  return a - b
end

function calculator.multiply(a, b)
  return a * b
end

function calculator.divide(a, b)
  if b == 0 then
    error("division by zero")
  end
  return a / b
end

describe("calculator", function()
  describe("add", function()
    it("adds two positive numbers", function()
      assert.are.equal(5, calculator.add(2, 3))
    end)

    it("handles negative numbers", function()
      assert.are.equal(-1, calculator.add(2, -3))
    end)

    it("returns zero when adding zeros", function()
      assert.are.equal(0, calculator.add(0, 0))
    end)
  end)

  describe("subtract", function()
    it("subtracts two numbers", function()
      assert.are.equal(1, calculator.subtract(3, 2))
    end)
  end)

  describe("multiply", function()
    it("multiplies two numbers", function()
      assert.are.equal(6, calculator.multiply(2, 3))
    end)

    it("returns zero when multiplying by zero", function()
      assert.are.equal(0, calculator.multiply(5, 0))
    end)
  end)

  describe("divide", function()
    it("divides two numbers", function()
      assert.are.equal(2, calculator.divide(6, 3))
    end)

    it("raises an error when dividing by zero", function()
      assert.has_error(function()
        calculator.divide(1, 0)
      end, "division by zero")
    end)
  end)
end)
