package main

import "fmt"

var WeatherCodesDay map[string]rune
var WeatherCodesNight map[string]rune

func SymbolTest() {
	WeatherCodesDay := map[string]rune{
		"Unkown":              '\ue374',
		"Cloudy":              '\ue302',
		"Fog":                 '\ue303',
		"HeavyRain":           '\ue318',
		"HeavyShowers":        '\ue318',
		"HeavySnow":           '\ue31a',
		"HeavySnowShowers":    '\ue31a',
		"LightRain":           '\ue308',
		"LightShowers":        '\ue308',
		"LightSleet":          '\ue3aa',
		"LightSleetShowers":   '\ue3aa',
		"LightSnow":           '\ue30a',
		"LightSnowShowers":    '\ue30a',
		"PartlyCloudy":        '\ue37b',
		"Sunny":               '\ue30d',
		"ThunderyHeavyRain":   '\ue31d',
		"ThunderyShowers":     '\ue31d',
		"ThunderySnowShowers": '\ue365',
		"VeryCloudy":          '\ue312',
	}

	WeatherCodesNight := map[string]rune{
		"Unkown":              '\ue374',
		"Cloudy":              '\ue37e',
		"Fog":                 '\ue346',
		"HeavyRain":           '\ue318',
		"HeavyShowers":        '\ue318',
		"HeavySnow":           '\ue31a',
		"HeavySnowShowers":    '\ue31a',
		"LightRain":           '\ue325',
		"LightShowers":        '\ue325',
		"LightSleet":          '\ue3ac',
		"LightSleetShowers":   '\ue3ac',
		"LightSnow":           '\ue361',
		"LightSnowShowers":    '\ue361',
		"PartlyCloudy":        '\ue379',
		"Sunny":               '\ue32b',
		"ThunderyHeavyRain":   '\ue31d',
		"ThunderyShowers":     '\ue31d',
		"ThunderySnowShowers": '\ue366',
		"VeryCloudy":          '\ue312',
	}

	for k, v := range WeatherCodesDay {
		fmt.Printf("%s: %c %c\n", k, v, WeatherCodesNight[k])
	}
}
