<?php
namespace Tests\Functional;

use \FunctionalTester;

class UserCest
{
    public function _before(FunctionalTester $I)
    {
    }

    public function _after(FunctionalTester $I)
    {
    }

    public function testSignup(FunctionalTester $I)
    {
        $I->wantTo('signup and check the user exists in database');

        $I->dontSeeInDatabase('user', array('email' => 'test@zf2.com'));

        $I->amOnPage('/user/register');
        $I->see('Register');
        $I->fillField('email', 'test@zf2.com');
        $I->fillField('password', 'strong-password');
        $I->fillField('passwordVerify', 'strong-password');
        $I->click('Register');

        $I->seeCurrentUrlEquals('/user');
        $I->seeInDatabase('user', array('email' => 'test@zf2.com'));
        $I->amSignedIn();
    }

    public function testCantSignupWithExistingEmail(FunctionalTester $I)
    {
        $I->wantTo('sign up with existing email and get an error');

        $I->seeInDatabase('user', array('email' => 'test@test.com'));

        $I->amOnPage('/user/register');
        $I->fillField('email', 'test@test.com');
        $I->fillField('password', 'strong-password');
        $I->fillField('passwordVerify', 'strong-password');
        $I->click('Register');

        $I->seeCurrentUrlEquals('/user/register');
        $I->see('A record matching the input was found');

        $I->seeInDatabase('user', array('email' => 'test@test.com'));
        $I->amNotSignedIn();
    }
}
