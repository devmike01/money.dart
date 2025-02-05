import '../money.dart';
import 'exchange_rate.dart';

typedef CodePair = String;

/// The [ExchangePlatform] allows you to register a set of [ExchangeRate]
/// which you can then use to do currency conversions.
/// We allow multiple [ExchangePlatform]s to exist to reflect
/// the fact that there multiple exchanges around the world.
///
/// To use an [ExchangePlatform] call register for each exchange rate.
/// If you only provide an exchange rate in one direction (AUD -> USD)
/// then it will calculate the inverse exchange rate if required.
/// In the real world you will probably need to provide exchange rates
/// in both directions as they are rarely the recipricol of each other.
class ExchangePlatform {
  final exchangeMap = <CodePair, ExchangeRate>{};

  void register(ExchangeRate exchangeRate) {
    exchangeMap[_generate(
            exchangeRate.fromCurrency.code, exchangeRate.toCurrency.code)] =
        exchangeRate;
  }

  // void registerExchangeRate(ExchangeRateMap exchangeRate) {
  //   exchangeMap[_generate(exchangeRate.from.code, exchangeRate.to.code)] =
  //       exchangeRate;
  // }

  Money exchangeTo(Money from, CurrencyCode to) {
    var exchangeRate = exchangeMap[_generate(from.currency.code, to)];

    if (exchangeRate != null) {
      return exchangeRate.applyRate(from);
    }

    /// try the inverse code pari
    exchangeRate = exchangeMap[_generate(
      to,
      from.currency.code,
    )];

    if (exchangeRate != null) {
      return exchangeRate.applyInverseRate(from);
    }
    throw UnknownExchangeRateException(from.currency.code, to);
  }

  CodePair _generate(CurrencyCode from, CurrencyCode to) {
    return '$from:$to';
  }
}

/// Thrown if an attempt is made to calcuate the value of a [Money] amount
/// in another currency for which there isn't a registered exchange rate.
class UnknownExchangeRateException implements MoneyException {
  /// The from currency code in the unknown exchange
  CurrencyCode from;

  /// The to  currency code in the unknown exchange
  CurrencyCode to;

  ///
  UnknownExchangeRateException(this.from, this.to);

  @override
  String toString() {
    return "An unknown currency exchange was attempted from: '$from' to: '$to'. Register the ExchangeRate"
        ' via [ExchangePlatform.register()] and try again.';
  }
}
