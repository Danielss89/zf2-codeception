<?php 
$I = new AcceptanceTester($scenario);
$I->wantTo('Check Index page contains elements');

$I->amOnPage('/');

$I->see('Welcome to');
$I->see('Zend Framework 2', '.zf-green');
$I->see('Follow Development', '.panel-heading .panel-title');
$I->seeLink('ZF2 Development Portal »');
$I->see('2005 - 2014');
