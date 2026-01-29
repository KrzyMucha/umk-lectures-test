<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260129000000 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Create offers table';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('CREATE TABLE offers (
            id SERIAL PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            description TEXT DEFAULT NULL
        )');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('DROP TABLE offers');
    }
}
