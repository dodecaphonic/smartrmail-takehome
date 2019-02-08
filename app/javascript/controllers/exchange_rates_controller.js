import { Controller } from "stimulus";
import * as echarts from "echarts";

export default class extends Controller {
  static targets = ["currency", "openRate", "closeRate", "minRate", "maxRate"];

  get selectedCurrency() {
    return this.data.get("selectedCurrency");
  }

  set selectedCurrency(value) {
    this.data.set("selectedCurrency", value);
  }

  get currencySelectors() {
    return this.element.querySelectorAll(".currency-switcher a");
  }

  connect() {
    this.switchToCurrency(this.selectedCurrency);
  }

  switchToCurrency(currency) {
    this.selectedCurrency = currency;

    this._updateDisplays();
    this._fetchExchangeRates();
    this._fetchLatestRate();
  }

  onSwitchCurrency(e) {
    const currency = e.target.dataset.currency;
    this.switchToCurrency(currency);
  }

  _updateDisplays() {
    this.currencyTarget.innerHTML = this.selectedCurrency;
    this.currencySelectors.forEach(btn => {
      if (btn.dataset.currency === this.selectedCurrency) {
        btn.classList.remove("bg-white");
        btn.classList.add("bg-gold");
      } else {
        btn.classList.add("bg-white");
        btn.classList.remove("bg-gold");
      }
    });
  }

  _fetchLatestRate() {
    fetch(`/exchange_rates/${this.selectedCurrency}`, {
      headers: new Headers({
        Accept: "application/json"
      })
    })
      .then(r => r.json())
      .then(this._massageRate.bind(this))
      .then(this._updateCurrentRate.bind(this))
      .catch(console.error);
  }

  _fetchExchangeRates() {
    fetch(
      `/exchange_rates?from_currency=${this.selectedCurrency}&period=intraday`,
      {
        headers: new Headers({
          Accept: "application/json"
        })
      }
    )
      .then(r => r.json())
      .then(rs => rs.map(this._massageRate.bind(this)))
      .then(this._updateGraph.bind(this))
      .catch(console.error);
  }

  _updateGraph(values) {
    this.chart = echarts.init(this.element.querySelector("#graph"));

    const rates = values.map(v => v.close);
    const times = values.map(v => v.point_in_time);

    console.log({
      min: rates.reduce((min, v) => Math.min(min, v), Infinity),
      max: rates.reduce((max, v) => Math.max(max, v), -Infinity)
    });

    this.chart.setOption({
      tooltip: {},
      legend: {
        data: ["Sales"]
      },
      series: [
        {
          areaStyle: {
            normal: {
              color: "#ffb700"
            }
          },
          lineStyle: {
            normal: "#ffffff"
          },
          data: rates,
          name: "Value",
          type: "line",
          min: rates.reduce((min, v) => Math.min(min, v), Infinity),
          max: rates.reduce((max, v) => Math.max(max, v), -Infinity)
        }
      ],
      xAxis: {
        data: times,
        axisLine: {
          lineStyle: {
            color: "#ffffff",
            width: 2
          }
        }
      },
      yAxis: {
        axisLine: {
          lineStyle: {
            color: "#ffffff",
            width: 2
          }
        },
        min: rates.reduce((min, v) => Math.min(min, v), Infinity) - 0.002,
        max: rates.reduce((max, v) => Math.max(max, v), -Infinity) + 0.002
      }
    });
  }

  _updateCurrentRate(rate) {
    this.openRateTarget.innerHTML = rate.open;
    this.closeRateTarget.innerHTML = rate.close;
  }

  _massageRate(rate) {
    return {
      ...rate,
      point_in_time: new Date(rate.point_in_time)
    };
  }
}
