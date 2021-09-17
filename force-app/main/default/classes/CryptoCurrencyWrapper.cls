public class CryptoCurrencyWrapper {

    public class Quote {
        public USD USD;
    }

    public Integer id;
    public String name;
    public String symbol;
    public String slug;
    public Integer num_market_pairs;
    public String date_added;
    public List<String> tags;
    public Double max_supply;
    public Double circulating_supply;
    public Double total_supply;
    public Integer is_active;
    public Platform platform;
    public Integer cmc_rank;
    public Integer is_fiat;
    public String last_updated;
    public Quote quote;
    

    public class Platform {
		public Integer id;
		public String name;
		public String symbol;
		public String slug;
		public String token_address;
	}

    public class USD {
        public Decimal price;
        public Decimal volume_24h;
        public Double percent_change_1h;
        public Double percent_change_24h;
        public Double percent_change_7d;
        public Double percent_change_30d;
        public Double percent_change_60d;
        public Double percent_change_90d;
        public Decimal market_cap;
        public String last_updated;
    }

    
    public static CryptoCurrencyModel parse(String json) {
        return (CryptoCurrencyModel) System.JSON.deserialize(json, CryptoCurrencyModel.class);
    }
}
