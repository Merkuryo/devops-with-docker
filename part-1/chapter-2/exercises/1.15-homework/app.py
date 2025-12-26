#!/usr/bin/env python3
"""
Simple temperature converter application
Converts between Celsius, Fahrenheit, and Kelvin
"""

def celsius_to_fahrenheit(c):
    return (c * 9/5) + 32

def celsius_to_kelvin(c):
    return c + 273.15

def fahrenheit_to_celsius(f):
    return (f - 32) * 5/9

def fahrenheit_to_kelvin(f):
    return (f - 32) * 5/9 + 273.15

def kelvin_to_celsius(k):
    return k - 273.15

def kelvin_to_fahrenheit(k):
    return (k - 273.15) * 9/5 + 32

def main():
    import sys
    
    # If running with piped input, handle batch mode
    if not sys.stdin.isatty():
        lines = sys.stdin.readlines()
        if len(lines) >= 2:
            choice = lines[0].strip()
            value = float(lines[1].strip())
            
            if choice == '1':
                result = celsius_to_fahrenheit(value)
                print(f"{value}°C = {result:.2f}°F")
            elif choice == '2':
                result = celsius_to_kelvin(value)
                print(f"{value}°C = {result:.2f}K")
            elif choice == '3':
                result = fahrenheit_to_celsius(value)
                print(f"{value}°F = {result:.2f}°C")
            elif choice == '4':
                result = fahrenheit_to_kelvin(value)
                print(f"{value}°F = {result:.2f}K")
            elif choice == '5':
                result = kelvin_to_celsius(value)
                print(f"{value}K = {result:.2f}°C")
            elif choice == '6':
                result = kelvin_to_fahrenheit(value)
                print(f"{value}K = {result:.2f}°F")
            return
    
    # Interactive mode
    print("Temperature Converter")
    print("====================")
    print("\n1. Celsius to Fahrenheit")
    print("2. Celsius to Kelvin")
    print("3. Fahrenheit to Celsius")
    print("4. Fahrenheit to Kelvin")
    print("5. Kelvin to Celsius")
    print("6. Kelvin to Fahrenheit")
    
    choice = input("\nSelect conversion (1-6): ")
    
    try:
        value = float(input("Enter temperature value: "))
        
        if choice == '1':
            result = celsius_to_fahrenheit(value)
            print(f"\n{value}°C = {result:.2f}°F")
        elif choice == '2':
            result = celsius_to_kelvin(value)
            print(f"\n{value}°C = {result:.2f}K")
        elif choice == '3':
            result = fahrenheit_to_celsius(value)
            print(f"\n{value}°F = {result:.2f}°C")
        elif choice == '4':
            result = fahrenheit_to_kelvin(value)
            print(f"\n{value}°F = {result:.2f}K")
        elif choice == '5':
            result = kelvin_to_celsius(value)
            print(f"\n{value}K = {result:.2f}°C")
        elif choice == '6':
            result = kelvin_to_fahrenheit(value)
            print(f"\n{value}K = {result:.2f}°F")
        else:
            print("Invalid choice")
    except ValueError:
        print("Invalid input")

if __name__ == "__main__":
    main()
