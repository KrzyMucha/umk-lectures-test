<?php

namespace App\Controller;

use App\Entity\Offer;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/offers')]
class OfferController extends AbstractController
{
    #[Route('', methods: ['GET'])]
    public function index(): JsonResponse
    {
        $offers = [new Offer(), new Offer()];
        
        return $this->json(
            array_map(fn(Offer $offer) => $offer->toArray(), $offers),
            Response::HTTP_OK,
            [],
            ['json_encode_options' => JSON_PRESERVE_ZERO_FRACTION]
        );
    }
}
