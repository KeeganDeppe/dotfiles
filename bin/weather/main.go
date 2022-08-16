package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

type Weather struct {
	Temp     float64
	Humidity int
	Icon     rune
	City     string
	State    string
}

type weathercode rune

const (
	CLEAR_DAY           weathercode = '\ue30d'
	CLEAR_NIGHT         weathercode = '\ue32b'
	PARTLY_CLOUDY_DAY   weathercode = '\ue302'
	PARTLY_CLOUDY_NIGHT weathercode = '\ue379'
	CLOUDY              weathercode = '\ue312'
	RAIN                weathercode = '\ue318'
	THUNDERSTORM        weathercode = '\ue31d'
	SNOW                weathercode = '\ue31a'
	FOG                 weathercode = '\ue313'
	DEGREES_F           weathercode = '\ue341'
	HUMIDITY            weathercode = '\ue373'
)

func (w *Weather) String() string {
	return fmt.Sprintf(" %c %.1f%c %d%c in %s, %s", w.Icon, w.Temp, DEGREES_F, w.Humidity, HUMIDITY, w.City, USStates[w.State]) // Output as ICON ##.#*F ##% in City, ST where the rune is a degree sign
}

func main() {
	city := os.Getenv("CITY")
	if city == "" {
		fmt.Print("No location found!")
		os.Exit(1)
	}
	city = strings.Trim(city, " \n")
	weathercmd := exec.Command("sh", "-c", "${HOME}/.dotfiles/bin/weather/weather.sh")
	var out bytes.Buffer
	weathercmd.Stdout = &out
	if err := weathercmd.Run(); err != nil {
		panic(err)
	}
	// parsing json time :D
	var temp map[string]interface{}
	if err := json.Unmarshal(out.Bytes(), &temp); err != nil {
		panic(err)
	}
	// fmting hell
	weather := &Weather{City: city}
	for k, v := range temp {
		if k == "main" {
			// weather info
			for nk, nv := range v.(map[string]interface{}) {
				if nk == "temp" {
					weather.Temp = nv.(float64)
				} else if nk == "humidity" {
					weather.Humidity = int(nv.(float64)) // this is as gross as it gets
				}
			}
		} else if k == "name" {
			weather.State = v.(string)
		} else if k == "weather" {
			m := v.([]interface{})
			for nk, nv := range m[0].(map[string]interface{}) {
				if nk == "icon" {
					weather.Icon = getIcon(nv.(string))
				}
			}
		}
	}
	fmt.Print(weather)
}
func tod(day bool, dayrune weathercode, nightrune weathercode) rune {
	if day {
		return rune(dayrune)
	}
	return rune(nightrune)
}

func getIcon(code string) rune {
	weather := strings.Trim(code, "nd") // trimming day or night tag
	var day bool
	if strings.Contains(code, "d") {
		day = true
	} else {
		day = false
	}

	switch weather {
	case "01":
		return tod(day, CLEAR_DAY, CLEAR_NIGHT) // clear skies
	case "02", "03":
		return tod(day, PARTLY_CLOUDY_DAY, PARTLY_CLOUDY_NIGHT) // small clouds
	case "04":
		return rune(CLOUDY) // big clouds with sun
	case "09", "10":
		return rune(RAIN)
	case "11":
		return rune(THUNDERSTORM)
	case "13":
		return rune(SNOW)
	case "50":
		return rune(FOG)
	default:
		return '\uFFFD' // question mark
	}
}
