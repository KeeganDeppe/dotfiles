package main

import (
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"

	"github.com/joho/godotenv"
)

type Weather struct {
	Temp       float64
	Humidity   int
	Icon       rune
	City       string
	LastPinged int64
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
	return fmt.Sprintf(" %c %.1f%c %d%c in %s", w.Icon, w.Temp, DEGREES_F, w.Humidity, HUMIDITY, w.City) // Output as ICON ##.#*F ##% in City, ST where the rune is a degree sign
}

func main() {
	// getting weather
	if err := exec.Command(os.ExpandEnv("$HOME/.dotfiles/bin/weather/weather.sh")).Run(); err != nil {
		panic(err)
	}
	// get up to date info
	loc := os.ExpandEnv(fmt.Sprintf("$HOME/.dotfiles/bin/weather/.env.location"))
	weath := os.ExpandEnv(fmt.Sprintf("$HOME/.dotfiles/bin/weather/.env.weather"))
	if err := godotenv.Load(weath, loc); err != nil {
		panic(err)
	}

	var humidity int
	var temp float64
	var err error

	city := os.Getenv("CITY")
	icon := getIcon(os.Getenv("ICON"))
	h := os.Getenv("HUMIDITY")
	t := os.Getenv("TEMP")
	if h != "" {
		hum, err := strconv.ParseInt(h, 10, 64)
		if err != nil {
			panic(err)
		}
		humidity = int(hum)
	}
	if t != "" {
		temp, err = strconv.ParseFloat(t, 64)
		if err != nil {
			panic(err)
		}
	}
	weather := &Weather{City: city, Icon: icon, Humidity: humidity, Temp: temp}
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
