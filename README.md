# NovaStore SQL

## Stack

SQL Server 2022 (T-SQL), Docker, VS Code with the SQL Server (mssql) extension.

## Getting started

```bash
git clone https://github.com/orewakm/novastore_sql.git
cd novastore_sql
docker compose up -d
```

Wait until `docker compose ps` shows the container as `healthy`, then run the script:

```bash
docker compose exec -T mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'NovaStore_2026!' -C -f 65001 < AkmuhammetYazlyyev_NovaStore_Proje.sql
```

You can also open the `.sql` file in VS Code, connect to `localhost,1433` as `sa` with the password from `compose.yaml` and **Trust server certificate** on, then run it.

On Apple Silicon, turn on **Use Rosetta for x86_64/amd64 emulation** in Docker Desktop settings first. SQL Server only ships an amd64 image.

## What it's for

NovaStore is the database of a small online store. It holds categories, products, customers, orders and order lines, and answers the store's report questions.

## How it works

- **Database:** `NovaStoreDB` with the `Turkish_CI_AS` collation, so Turkish characters are stored correctly. The script drops and recreates it, so it can be run again.
- **Tables:** `Categories`, `Products`, `Customers`, `Orders`, `OrderDetails`, linked with foreign keys. Emails are unique, stock defaults to `0` and the order date defaults to now.
- **Data:** 5 categories, 12 products, 6 customers, 10 orders and 17 order lines. Order totals are calculated from the order lines.
- **Reports:** six queries using `JOIN`, `LEFT JOIN`, `GROUP BY`, `COUNT`, `SUM` and `DATEDIFF`.
- **View:** `vw_SiparisOzet` shows every order line with the customer, the order date, the product and the quantity.
- **Backup:** a full backup to `C:\Yedek\NovaStoreDB.bak`. In Docker this is `./yedek/NovaStoreDB.bak`.

## Files

| File | What's in it |
| --- | --- |
| `AkmuhammetYazlyyev_NovaStore_Proje.sql` | The whole script, from creating the database to the backup |
| `AkmuhammetYazlyyev_NovaStore_Proje.docx` | The project report in Turkish, with explanations and screenshots |
| `AkmuhammetYazlyyev_NovaStore_Proje.png` | The ER diagram |
| `screenshots/` | The result of every table, query, the view and the backup |
| `compose.yaml` | The local SQL Server |
