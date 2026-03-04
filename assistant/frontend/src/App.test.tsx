import { render, screen } from "@testing-library/react"
import { expect, test } from "vitest"
import App from "./App"

test("renders Dorje heading", () => {
  render(<App />)
  expect(screen.getByText("Dorje")).toBeInTheDocument()
})
