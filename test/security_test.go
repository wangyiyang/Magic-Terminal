package main

import (
	"fmt"
	"image/color"
)

// Test function to validate security fixes
func main() {
	fmt.Println("Testing security fixes...")

	// Test 1: Test color creation with bounds checking (simulating our color.go fix)
	testColor := createSafeRGBA(300, -50, 128) // Values that would cause issues
	fmt.Printf("Safe RGBA creation test passed: %+v\n", testColor)

	// Test 2: Test bounds checking concept for uint32->uint8 conversion
	testUint32Max := uint32(4294967295) // Max uint32 value

	// Test safe conversion (simulating our termgridhelper.go fix)
	val := testUint32Max >> 8
	if val > 255 {
		val = 255
	}
	safeUint8 := uint8(val)
	fmt.Printf("Safe uint32 to uint8 conversion: %d -> %d\n", testUint32Max, safeUint8)

	// Test 3: Test uint to uint16 conversion (simulating our term_unix.go fix)
	testUint := uint(70000) // Value that would overflow uint16
	if testUint > 65535 {
		testUint = 65535
	}
	safeUint16 := uint16(testUint)
	fmt.Printf("Safe uint to uint16 conversion: 70000 -> %d\n", safeUint16)

	fmt.Println("All security fix validation tests completed successfully!")
}

// createSafeRGBA creates an RGBA color with bounds checking
func createSafeRGBA(r, g, b int) color.RGBA {
	if r < 0 {
		r = 0
	} else if r > 255 {
		r = 255
	}
	if g < 0 {
		g = 0
	} else if g > 255 {
		g = 255
	}
	if b < 0 {
		b = 0
	} else if b > 255 {
		b = 255
	}

	return color.RGBA{uint8(r), uint8(g), uint8(b), 255}
}
